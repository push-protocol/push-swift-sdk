import Foundation

extension PushUser {
  public struct UpdatedUserProfile: Codable {
    let name: String?
    let picture: String?
    let blockedUsersList: [String]?

    public init(name: String? = nil, picture: String? = nil, blockedUsersList: [String]? = nil) {
      self.name = name
      self.picture = picture
      self.blockedUsersList =
        blockedUsersList != nil ? walletsToPCAIP10(accounts: blockedUsersList!) : nil
    }
  }

  public static func blockUsers(addressesToBlock:[String], account: String, pgpPrivateKey: String,env:ENV) async throws->Bool {
    let updated = PushUser.UpdatedUserProfile(
      blockedUsersList: addressesToBlock)

    return  try await PushUser.updateUserProfile(
      account: account, pgpPrivateKey: pgpPrivateKey, updatedProfile: updated, env:env
    )
  }

  public static func updateUserProfile(
    account: String, pgpPrivateKey: String, updatedProfile: PushUser.UpdatedUserProfile, env: ENV
  ) async throws -> Bool {
    let user = try await Push.PushUser.get(account: account, env: env)!
    let (newProfile, updateUserHash) = try getUpdateProfileHash(
      user: user, newProfile: updatedProfile)

    let signature = try Pgp.sign(
      message: updateUserHash, privateKey: pgpPrivateKey)
    let sigType = "pgpv2"
    let verificationProof = "\(sigType):\(signature)"
    
    print(verificationProof)

    let payload = UpdateUserPayload(
      name: newProfile.name, desc: newProfile.desc, picture: newProfile.picture,
      blockedUsersList: newProfile.blockedUsersList,
      verificationProof: verificationProof)
    return try await updateUserService(payload: payload, account: account, env: env)
  }

  static func updateUserService(payload: UpdateUserPayload, account: String, env: ENV)
    async throws
    -> Bool
  {
    let url = PushEndpoint.updateUser(account: walletToPCAIP10(account: account), env: env)
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(payload)

    let (data, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

        print(String(data:request.httpBody!,encoding: .utf8)!)
    guard (200...299).contains(httpResponse.statusCode) else {
      print(httpResponse.statusCode, String(data: data, encoding: .utf8)!)
      throw URLError(.badServerResponse)
    }

    if httpResponse.statusCode == 201{
    //   print(httpResponse.statusCode, String(data: data, encoding: .utf8)!)
        return true
    }

    return false

  }
}

struct UpdateUserPayload: Codable {
  var name: String?
  var desc: String
  var picture: String
  var blockedUsersList: [String]
  var verificationProof: String
}

struct UpdateUseProfile: Codable {
  public var name: String?
  public var desc: String
  public var picture: String
  public var blockedUsersList: [String]
}

func getUpdateProfileHash(user: PushUser, newProfile: PushUser.UpdatedUserProfile) throws -> (
  UpdateUseProfile, String
) {

  let name =
    newProfile.name != nil
    ? "\"\(newProfile.name!)\"" : user.name != nil ? "\"\(user.name!)\"" : "null"
  let picture =
    newProfile.picture != nil
    ? "\"\(newProfile.picture!)\"" : "\"\(user.profilePicture)\""
  let blockedUsersList =
    newProfile.blockedUsersList != nil
    ? newProfile.blockedUsersList!
    : user.blockedUsersList != nil ? user.blockedUsersList! : []

  let jsonString =
    "{\"name\":\(name),\"desc\":\(name),\"picture\":\(picture),\"blockedUsersList\":\(blockedUsersList)}"

    // print("json string was",jsonString)

  let newUserProfile = UpdateUseProfile(
    name: (name == "null" ? nil : name.replacingOccurrences(of: "\"", with: "")),
    desc: name.replacingOccurrences(of: "\"", with: ""),
    picture: picture.replacingOccurrences(of: "\"", with: ""),
    blockedUsersList: blockedUsersList)
  let hash = generateSHA256Hash(msg: jsonString)

  return (newUserProfile, hash)
}
