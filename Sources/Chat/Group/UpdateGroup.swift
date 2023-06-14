import Foundation

extension PushChat {
  public static func updateGroup(
    updatedGroup: PushChat.PushGroup, adminAddress: String, adminPgpPrivateKey: String, env: ENV
  ) async throws -> PushGroup {
    do {

      let updatedGroupOptions = try UpdateGroupOptions(
        group: updatedGroup, creatorPgpPrivateKey: adminPgpPrivateKey)

      let createGroupInfoHash = try getUpdateGroupHash(options: updatedGroupOptions)
      let signature = try Pgp.sign(
        message: createGroupInfoHash, privateKey: updatedGroupOptions.creatorPgpPrivateKey)
      let sigType = "pgp"
      let verificationProof = "\(sigType):\(signature):\(updatedGroupOptions.creatorAddress)"

      let payload = UpdateGroupPlayload(
        options: updatedGroupOptions, verificationProof: verificationProof)

      return try await updateGroupService(
        payload: payload, chatId: updatedGroup.chatId, env: updatedGroupOptions.env)

    } catch {
      throw GroupChatError.RUNTIME_ERROR(
        "[Push SDK] - API  - Error - API update GroupChat -: \(error)")
    }
  }

  struct UpdateGroupPlayload: Encodable {
    var groupName: String
    var groupDescription: String
    var groupImage: String
    var members: [String]
    var admins: [String]
    var address: String
    var verificationProof: String

    public init(options: UpdateGroupOptions, verificationProof: String) {
      groupName = options.name
      groupDescription = options.description
      members = options.members
      groupImage = options.image
      address = options.creatorAddress
      admins = options.admins
      self.verificationProof = verificationProof
    }
  }

  static func updateGroupService(payload: UpdateGroupPlayload, chatId: String, env: ENV)
    async throws
    -> PushChat.PushGroup
  {
    let url = try PushEndpoint.updatedChatGroup(chatId: chatId, env: env).url
    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(payload)

    let (data, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      print(String(data: data, encoding: .utf8)!)
      throw URLError(.badServerResponse)
    }

    let groupData = try JSONDecoder().decode(PushGroup.self, from: data)
    return groupData

  }

}

public struct UpdateGroupOptions {
  public var name: String
  public var description: String
  public var image: String
  public var members: [String]
  public var admins: [String]
  public var chatId: String

  public var creatorAddress: String
  public var creatorPgpPrivateKey: String
  public var env: ENV = ENV.STAGING

  public init(
    group: PushChat.PushGroup, creatorPgpPrivateKey: String, env: ENV = ENV.STAGING
  ) throws {

    let memebersAddresses = group.members.map { $0.wallet }
    let adminsAddresses = [group.groupCreator]

    self.name = group.groupName
    self.description = group.groupDescription
    self.image = group.groupImage
    self.members = memebersAddresses
    self.admins = adminsAddresses
    self.chatId = group.chatId

    self.creatorAddress = group.groupCreator
    self.creatorPgpPrivateKey = creatorPgpPrivateKey
    self.env = env

    // validate the options
    try updateGroupOptionValidator(self)

    // format the addresses
    self.creatorAddress = walletToPCAIP10(account: creatorAddress)
    self.members = walletsToPCAIP10(accounts: self.members)
  }
}

func getUpdateGroupHash(options: UpdateGroupOptions) throws -> String {
  struct CreateGroupStruct: Codable {
    let groupName: String
    let groupDescription: String
    let members: [String]
    let admins: [String]
    let groupImage: String
    let groupCreator: String
    let chatId: String

    func toJSONString() throws -> String {
      return
        "{\"groupName\":\"\(groupName)\",\"groupDescription\":\"\(groupDescription)\",\"groupImage\":\"\(groupImage)\",\"members\":\(members),\"admins\":\(admins),\"chatId\":\"\(chatId)\"}"
    }
  }

  let createGroupStruct = try CreateGroupStruct(
    groupName: options.name,
    groupDescription: options.description,
    members: options.members,
    admins: options.admins,
    groupImage: options.image,
    groupCreator: options.creatorAddress,
    chatId: options.chatId
  ).toJSONString()

  let hash = generateSHA256Hash(msg: createGroupStruct)

  return hash
}
