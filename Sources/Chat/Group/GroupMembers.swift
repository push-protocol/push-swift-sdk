import Foundation

extension PushChat {
    public struct UpdateGroupMemberOptions {
        var account: String
        let chatId: String
        var upsert: UpsertData
        let remove: [String]
        var pgpPrivateKey: String
        
        init(account: String, chatId: String, upsert: UpsertData = UpsertData() , remove: [String]  = [], pgpPrivateKey: String) {
            self.account = account
            self.chatId = chatId
            self.upsert = upsert
            self.remove = remove
            self.pgpPrivateKey = pgpPrivateKey
        }
    }

    public struct UpsertData {
        let members: [String]
        let admins: [String]
        
        init(members: [String] = [], admins: [String] = []) {
            self.members = members
            self.admins = admins
        }

        func toJson() -> [String: [String]] {
            return [
                "members": members,
                "admins": admins,
            ]
        }
    }

    public static func updateGroupMember(options: UpdateGroupMemberOptions, env: ENV) async throws -> PushChat.PushGroupInfoDTO {
        do {
            try validateGroupMemberUpdateOptions(chatId: options.chatId, upsert: options.upsert, remove: options.remove)

            var convertedUpsert = [String: [String]]()
            for (key, value) in options.upsert.toJson() {
                convertedUpsert[key] = value.map { walletToPCAIP10(account: $0) }
            }

            let convertedRemove = options.remove.map { walletToPCAIP10(account: $0) }

            guard let connectedUser = try await PushUser.get(account: options.account, env: env)

            else {
                fatalError("\(options.account) not found")
            }

            let group = try await PushChat.getGroupInfoDTO(chatId: options.chatId, env: env)

            var encryptedSecret: String?
            if !group.isPublic {
                if  group.encryptedSecret != nil {
                    guard let isMember = try await getGroupMemberStatus(chatId: options.chatId, did: connectedUser.did, env: env)?.isMember else {
                        fatalError("Failed to determine group membership")
                    }

                    let removeParticipantSet = Set(convertedRemove.map { $0.lowercased() })

                    let groupMembers = try await getAllGroupMembersPublicKeysV2(chatId: options.chatId, env: env)
                    var sameMembers = true

                    for member in groupMembers! {
                        if removeParticipantSet.contains(member.did.lowercased()) {
                            sameMembers = false
                            break
                        }
                    }

                    if !sameMembers || !isMember {
                        let secretKey = AESGCMHelper.generateRandomSecret(length: 15)
                        var publicKeys = [String]()

                        for member in groupMembers! {
                            if !removeParticipantSet.contains(member.did.lowercased()) {
                                publicKeys.append(member.publicKey)
                            }
                        }

                        if !isMember {
                            publicKeys.append(connectedUser.publicKey)
                        }

                        encryptedSecret = try Pgp.pgpEncryptV2(message: secretKey, pgpPublicKeys: publicKeys)
                    }
                }
            }

            let hash = try getGroupmemberUpdateHash(upsert: convertedUpsert, remove: convertedRemove, encryptedSecret: encryptedSecret!)
            
            let signature = try Pgp.sign(message: hash, privateKey: options.pgpPrivateKey)
            let sigType = "pgpv2"
            let deltaVerificationProof = "\(sigType):\(signature):\(walletToPCAIP10(account: options.account))"
           
            return try await updateMemberService(chatId: options.chatId, payload: UpdateMembersPayload(upsert: convertedUpsert, remove: convertedRemove, encryptedSecret: encryptedSecret!, deltaVerificationProof: deltaVerificationProof), env: env)
          
        } catch {
            fatalError("Error: \(error.localizedDescription)")
        }
    }
    
    static func updateMemberService(chatId:String, payload: UpdateMembersPayload, env:ENV)  async throws
    -> PushChat.PushGroupInfoDTO
  {

    let url = try PushEndpoint.updateGroupMembers(chatId: chatId, env: env).url
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(payload)

    let (data, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let groupData = try JSONDecoder().decode(PushGroupInfoDTO.self, from: data)
    return groupData

  }
    
    struct UpdateMembersPayload : Codable {
        let upsert:  [String: [String]]
        let remove: [String]
        let encryptedSecret: String
        let deltaVerificationProof: String
    }

    static func getGroupmemberUpdateHash(upsert: [String: [String]]
                                         , remove: [String]
                                         , encryptedSecret: String) throws -> String {
        struct UpdateMemberStruct: Codable {
            let upsert:  [String: [String]]
            let remove: [String]
            let encryptedSecret: String
            
            func toJSONString() throws -> String {
                    let upsertJSON = try JSONSerialization.data(withJSONObject: upsert)
                    let upsertString = String(data: upsertJSON, encoding: .utf8) ?? "{}"
                    
                    let removeJSON = try JSONSerialization.data(withJSONObject: remove)
                    let removeString = String(data: removeJSON, encoding: .utf8) ?? "[]"
                    
                    return """
                    {
                        "upsert": \(upsertString),
                        "remove": \(removeString),
                        "encryptedSecret": "\(encryptedSecret)"
                    }
                    """
                }
            
        }
        
        let updateMember = try UpdateMemberStruct(upsert: upsert, remove: remove, encryptedSecret: encryptedSecret).toJSONString()
        
        return generateSHA256Hash(msg: updateMember)
    }

    static func validateGroupMemberUpdateOptions(chatId: String, upsert: UpsertData, remove: [String]) throws {
        if chatId.isEmpty {
            fatalError("chatId cannot be null or empty")
        }

        // Validating upsert object
        let allowedRoles = ["members", "admins"]

        let upsertJson = upsert.toJson()
        for (role, value) in upsertJson {
            if !allowedRoles.contains(role) {
                fatalError("Invalid role: \(role). Allowed roles are \(allowedRoles.joined(separator: ", ")).")
            }

            if value.count > 1000 {
                fatalError("\(role) array cannot have more than 1000 addresses.")
            }

            for address in value {
                if isValidETHAddress(address: address) {
                    fatalError("Invalid address found in \(role) list.")
                }
            }
        }

        // Validating remove array
        if remove.count > 1000 {
            fatalError("Remove array cannot have more than 1000 addresses.")
        }

        for address in remove {
            if isValidETHAddress(address: address) {
                fatalError("Invalid address found in remove list.")
            }
        }
    }
}
