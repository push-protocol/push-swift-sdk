import Foundation

extension PushChat {

  public static func createGroup(options: CreateGroupOptions) async throws -> PushGroupInfoDTO {
    do {
      let payload = try CreateGroupPlayload(options: options)
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
    -> PushChat.PushGroupInfoDTO
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
      throw URLError(.badServerResponse)
    }

    let groupData = try JSONDecoder().decode(PushGroupInfoDTO.self, from: data)
    return groupData

  }
}

struct CreateGroupPlayload: Encodable {
  var groupName: String
  var groupDescription: String
  var groupImage: String

  var rules: [String: String]
  var isPublic: Bool
  var groupType: String = "default"
  var profileVerificationProof: String

  var config: Config

  var members: [String]
  var admins: [String] = []
  var idempotentVerificationProof: String

  struct Config: Encodable {
    var meta: String?
    var scheduleAt: String?
    var scheduleEnd: String?
    var status: String?
    var configVerificationProof: String

    private enum CodingKeys: String, CodingKey {
      case meta, scheduleAt, scheduleEnd, status, configVerificationProof
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(meta, forKey: .meta)
      try container.encode(scheduleAt, forKey: .scheduleAt)
      try container.encode(scheduleEnd, forKey: .scheduleEnd)
      try container.encode(status, forKey: .status)
      try container.encode(configVerificationProof, forKey: .configVerificationProof)
    }
  }

  public init(options: PushChat.CreateGroupOptions) throws {
    groupName = options.name
    groupDescription = options.description
    groupImage = options.image

    rules = [String: String]()
    isPublic = options.isPublic

    members = options.members

    idempotentVerificationProof = try getIdempotentVerificationProof(options: options)
    profileVerificationProof = try getProfileVerificationProof(options: options)

    config = Config(configVerificationProof: try getConfigVerificationProof(options: options))

  }
}

func getProfileVerificationProof(options: PushChat.CreateGroupOptions) throws -> String {
  let profileHash = try getCreateGroupProfileVerificationHash(options: options)
  let signature = try Pgp.sign(
    message: profileHash, privateKey: options.creatorPgpPrivateKey)

  let connectedUserDID = walletToPCAIP10(account: options.creatorAddress)
  let sigType = "pgpv2"
  let verificationProof =
    "\(sigType):\(signature):\(connectedUserDID)"
  return verificationProof
}

func getCreateGroupProfileVerificationHash(options: PushChat.CreateGroupOptions) throws -> String {
  let jsonString =
    "{\"groupName\":\"\(options.name)\",\"groupDescription\":\"\(options.description)\",\"groupImage\":\"\(options.image)\",\"rules\":{},\"isPublic\":\(options.isPublic),\"groupType\":\"default\"}"

  let hash = generateSHA256Hash(msg: jsonString)

  return hash
}

func getConfigVerificationProof(options: PushChat.CreateGroupOptions) throws -> String {
  let profileHash = try getCreateGroupConfigVerificationHash(options: options)
  let signature = try Pgp.sign(
    message: profileHash, privateKey: options.creatorPgpPrivateKey)

  let connectedUserDID = walletToPCAIP10(account: options.creatorAddress)
  let sigType = "pgpv2"
  let verificationProof =
    "\(sigType):\(signature):\(connectedUserDID)"
  return verificationProof
}

func getCreateGroupConfigVerificationHash(options: PushChat.CreateGroupOptions) throws -> String {
  let jsonString =
    "{\"meta\":null,\"scheduleAt\":null,\"scheduleEnd\":null,\"status\":null}"

  let hash = generateSHA256Hash(msg: jsonString)

  return hash
}

func getIdempotentVerificationProof(options: PushChat.CreateGroupOptions) throws -> String {
  let profileHash = try getCreateGroupIdempotentHash(options: options)
  let signature = try Pgp.sign(
    message: profileHash, privateKey: options.creatorPgpPrivateKey)

  let connectedUserDID = walletToPCAIP10(account: options.creatorAddress)
  let sigType = "pgpv2"
  let verificationProof =
    "\(sigType):\(signature):\(connectedUserDID)"
  return verificationProof
}

func getCreateGroupIdempotentHash(options: PushChat.CreateGroupOptions) throws -> String {
  let jsonString =
    "{\"members\":\(options.members),\"admins\":[]}"

  let hash = generateSHA256Hash(msg: jsonString)

  return hash
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
