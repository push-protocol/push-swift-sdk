import Foundation

extension PushChat {

  public static func createGroup(options: CreateGroupOptions) async throws -> PushGroup {
    do {

      let createGroupInfoHash = try getCreateGroupHash(options: options)
      let signature = try Pgp.sign(
        message: createGroupInfoHash, privateKey: options.creatorPgpPrivateKey)

      let sigType = "pgp"
      let verificationProof = "\(sigType):\(signature)"

      let payload = CreateGroupPlayload(options: options, verificationProof: verificationProof)
      return try await createGroupService(payload: payload, env: options.env)
    } catch {
      throw GroupChatError.RUNTIME_ERROR(
        "[Push SDK] - API  - Error - API create GroupChat -: \(error)")
    }
  }

  public struct CreateGroupOptions {
    public var name: String
    public var description: String
    public var image: String
    public var members: [String]
    public var isPublic: Bool

    public var creatorAddress: String
    public var creatorPgpPrivateKey: String
    public var env: ENV = ENV.STAGING

    public init(
      name: String, description: String, image: String, members: [String],
      isPublic: Bool, creatorAddress: String, creatorPgpPrivateKey: String, env: ENV = ENV.STAGING
    ) throws {
      self.name = name
      self.description = description
      self.image = image
      self.members = members
      self.isPublic = isPublic

      self.creatorAddress = creatorAddress
      self.creatorPgpPrivateKey = creatorPgpPrivateKey
      self.env = env

      // remove if group creator from the admin list
      // if let adminIndex = self.admins.firstIndex(of: self.creatorAddress) {
      //   self.admins.remove(at: adminIndex)
      // }

      // remove if group creator from the members list
      if let adminIndex = self.members.firstIndex(of: self.creatorAddress) {
        self.members.remove(at: adminIndex)
      }

      // validate the options
      try createGroupOptionValidator(self)

      // format the addresses
      self.creatorAddress = walletToPCAIP10(account: creatorAddress)
      self.members = walletsToPCAIP10(accounts: self.members)
    }

  }

  static func createGroupService(payload: CreateGroupPlayload, env: ENV) async throws
    -> PushChat.PushGroup
  {
    let url = try PushEndpoint.createChatGroup(env: env).url
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
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

struct CreateGroupPlayload: Encodable {
  var groupName: String
  var groupDescription: String
  var members: [String]
  var groupImage: String
  var isPublic: Bool
  var admins: [String] = []
  var contractAddressNFT: String?
  var numberOfNFTs: Int?
  var contractAddressERC20: String?
  var numberOfERC20: Int?
  var groupCreator: String
  var verificationProof: String
  var meta: String?

  public init(options: PushChat.CreateGroupOptions, verificationProof: String) {
    groupName = options.name
    groupDescription = options.description
    members = options.members
    groupImage = options.image
    isPublic = options.isPublic
    groupCreator = options.creatorAddress
    self.verificationProof = verificationProof
  }
}

func getCreateGroupHash(options: PushChat.CreateGroupOptions) throws -> String {
  struct CreateGroupStruct: Codable {
    let groupName: String
    let groupDescription: String
    let members: [String]
    let groupImage: String
    let isPublic: Bool
    let contractAddressNFT: String?
    let numberOfNFTs: Int32
    let contractAddressERC20: String?
    let numberOfERC20: Int32
    let groupCreator: String

    func toJSONString() throws -> String {
      return
        "{\"groupName\":\"\(groupName)\",\"groupDescription\":\"\(groupDescription)\",\"members\":\(members),\"groupImage\":\"\(groupImage)\",\"admins\":[],\"isPublic\":\(isPublic),\"contractAddressNFT\":null,\"numberOfNFTs\":0,\"contractAddressERC20\":null,\"numberOfERC20\":0,\"groupCreator\":\"\(groupCreator)\"}"
    }
  }

  let createGroupStruct = try CreateGroupStruct(
    groupName: options.name,
    groupDescription: options.description,
    members: options.members,
    groupImage: options.image,
    isPublic: options.isPublic,
    contractAddressNFT: "null",
    numberOfNFTs: 0,
    contractAddressERC20: "null",
    numberOfERC20: 0,
    groupCreator: options.creatorAddress
  ).toJSONString()

  let hash = generateSHA256Hash(msg: createGroupStruct)

  return hash
}
