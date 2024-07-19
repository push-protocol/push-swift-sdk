import Foundation

extension PushUser {
    public static func blockUsers(
        addressesToBlock: [String], account: String, pgpPrivateKey: String, env: ENV
    ) async throws {
        var currentUserProfile = try await PushUser.get(account: account, env: env)!.profile

        var _addressToBlock: [String] =
            currentUserProfile.blockedUsersList != nil ? currentUserProfile.blockedUsersList! : []
        _addressToBlock += walletsToPCAIP10(accounts: addressesToBlock)

        currentUserProfile.blockedUsersList = _addressToBlock

        try await PushUser.updateUserProfile(
            account: account, pgpPrivateKey: pgpPrivateKey, newProfile: currentUserProfile, env: env
        )
    }

    public static func unblockUsers(
        addressesToUnblock: [String], account: String, pgpPrivateKey: String, env: ENV
    ) async throws {
        var currentUserProfile = try await PushUser.get(account: account, env: env)!.profile
        var _addressToBlock: [String] = []

        let addressAlreadyBlock: [String] =
            currentUserProfile.blockedUsersList != nil ? currentUserProfile.blockedUsersList! : []
        let _addressesToUnblock = walletsToPCAIP10(accounts: addressesToUnblock)

        for addrs in addressAlreadyBlock {
            if !_addressesToUnblock.contains(addrs) {
                _addressToBlock += [addrs]
            }
        }

        currentUserProfile.blockedUsersList = _addressToBlock
        return try await PushUser.updateUserProfile(
            account: account, pgpPrivateKey: pgpPrivateKey, newProfile: currentUserProfile, env: env
        )
    }

    public static func updateUserProfile(
        account: String, pgpPrivateKey: String, newProfile: PushUser.UserProfile, env: ENV
    ) async throws {
        let (newProfile, updateUserHash) = try getUpdateProfileHash(newProfile: newProfile)

        let signature = try Pgp.sign(
            message: updateUserHash, privateKey: pgpPrivateKey)
        let sigType = "pgpv2"
        let verificationProof = "\(sigType):\(signature)"

        let payload = UpdateUserPayload(
            name: newProfile.name,
            desc: newProfile.desc,
            picture: newProfile.picture,
            blockedUsersList: newProfile.blockedUsersList,
            verificationProof: verificationProof)

        try await updateUserService(payload: payload, account: account, env: env)
    }

    static func updateUserService(payload: UpdateUserPayload, account: String, env: ENV)
    async throws {
        let url = PushEndpoint.updateUser(account: walletToPCAIP10(account: account), env: env)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)

        let (data, res) = try await URLSession.shared.data(for: request)

        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            print(httpResponse.statusCode, String(data: data, encoding: .utf8)!)
            throw URLError(.badServerResponse)
        }
    }
}

struct UpdateUserPayload: Codable {
    var name: String?
    var desc: String?
    var picture: String?
    var blockedUsersList: [String]
    var verificationProof: String

    private enum CodingKeys: String, CodingKey {
        case name, desc, picture, blockedUsersList, verificationProof
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: .name)
        try container.encode(desc, forKey: .desc)
        try container.encode(picture, forKey: .picture)
        try container.encode(blockedUsersList, forKey: .blockedUsersList)
        try container.encode(verificationProof, forKey: .verificationProof)
    }
}

struct UpdateUseProfile: Codable {
    public var name: String?
    public var desc: String?
    public var picture: String?
    public var blockedUsersList: [String]
}

func getUpdateProfileHash(newProfile: PushUser.UserProfile) throws -> (
    UpdateUseProfile, String
) {
    let newUserProfile = UpdateUseProfile(
        name: newProfile.name,
        desc: newProfile.desc,
        picture: newProfile.picture,
        blockedUsersList: newProfile.blockedUsersList!)

    let name = newProfile.name == nil ? "null" : "\"\(newProfile.name!)\""
    let desc = newProfile.desc == nil ? "null" : "\"\(newProfile.desc!)\""
    let picture = "\"\(newProfile.picture)\""

    let blockUserAddresses = flatten_address_list(addresses: newProfile.blockedUsersList!)
    let jsonString =
        "{\"name\":\(name),\"desc\":\(desc),\"picture\":\(picture),\"blockedUsersList\":\(blockUserAddresses)}"
    let hash = generateSHA256Hash(msg: jsonString)

    return (newUserProfile, hash)
}

public func flatten_address_list(addresses: [String]) -> String {
    var res = "["
    var counter = 0
    for el in addresses {
        res += "\"\(el)\""
        if counter + 1 != addresses.count {
            res += ","
        }
        counter += 1
    }
    res += "]"

    return res
}
