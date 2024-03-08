import Foundation

extension PushChat {
  struct SendIntentAPIOptions {

  }

  struct SendMessagePayload: Encodable {
    var fromDID: String
    var toDID: String
    var fromCAIP10: String
    var toCAIP10: String
    var messageContent: String
    var messageObj: String?
    var messageType: String
    var signature: String
    var encType: String
    var encryptedSecret: String?
    var sigType: String
    var verificationProof: String?
    var sessionKey: String?

    private enum CodingKeys: String, CodingKey {
      case fromDID, toDID, fromCAIP10, toCAIP10, messageContent, messageObj, messageType, signature,
        encType,
        encryptedSecret, sigType, verificationProof, sessionKey
    }

    func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)

      try container.encode(fromDID, forKey: .fromDID)
      try container.encode(toDID, forKey: .toDID)
      try container.encode(fromCAIP10, forKey: .fromCAIP10)
      try container.encode(toCAIP10, forKey: .toCAIP10)
      try container.encode(messageContent, forKey: .messageContent)
      try container.encode(messageObj, forKey: .messageObj)

      try container.encode(messageType, forKey: .messageType)
      try container.encode(signature, forKey: .signature)
      try container.encode(encType, forKey: .encType)
      try container.encode(encryptedSecret, forKey: .encryptedSecret)

      try container.encode(sigType, forKey: .sigType)
      try container.encode(verificationProof, forKey: .verificationProof)
      try container.encode(sessionKey, forKey: .sessionKey)
    }
  }

  public enum MessageType: String {
    case Text = "Text"
    case Image = "Image"
    case Reaction = "Reaction"
    case Reply = "Reply"
    case MediaEmbed = "MediaEmbed"
  }

  public struct SendOptions {
    public var messageContent = ""
    public var messageType: MessageType
    public var receiverAddress: String
    public var account: String
    public var pgpPrivateKey: String
    public var senderPgpPubicKey: String?
    public var receiverPgpPubicKey: String?
    public var processMessage: String?
    public var reference: String?
    public var env: ENV = .STAGING

    public enum Reactions: String {
      case THUMBSUP = "\u{1F44D}"
      case THUMBSDOWN = "\u{1F44E}"
      case HEART = "\u{2764}\u{FE0F}"
      case CLAP = "\u{1F44F}"
      case LAUGH = "\u{1F602}"
      case SAD = "\u{1F622}"
      case ANGRY = "\u{1F621}"
      case SURPRISE = "\u{1F632}"
      case FIRE = "\u{1F525}"
    }

    public init(
      messageContent: String, messageType: String, receiverAddress: String, account: String,
      pgpPrivateKey: String, refrence: String? = nil, env: ENV = .STAGING
    ) {
      self.messageContent = messageContent
      self.messageType = MessageType(rawValue: messageType)!
      self.receiverAddress = walletToPCAIP10(account: receiverAddress)
      self.account = walletToPCAIP10(account: account)
      self.pgpPrivateKey = pgpPrivateKey
      self.reference = refrence
      self.env = env
    }

      public func getMessageObjJSON() throws -> String {
          switch messageType {
          case .Text, .Image, .MediaEmbed:
              return try getJsonStringFromKV([
                ("content", self.messageContent)
              ])
          case .Reaction:
              return try getJsonStringFromKV([
                ("content", self.messageContent),
                ("refrence", self.reference!),
              ])
          case .Reply:
              return """
            {"content":{"messageType":"Text","messageObj":{"content":"\(self.messageContent)"}},"reference":"\(self.reference!)"}
          """.trimmingCharacters(in: .whitespaces)
          }
      }
  }

  static func sendIntentService(payload: SendMessagePayload, env: ENV) async throws -> Message {
    let url = try PushEndpoint.sendChatIntent(env: env).url
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

    do {
      return try JSONDecoder().decode(Message.self, from: data)
    } catch {
      print("[Push SDK] - API \(error.localizedDescription)")
      throw error
    }
  }

  static func sendMessageService(payload: SendMessagePayload, env: ENV) async throws -> Message {
    let url = try PushEndpoint.sendChatMessage(env: env).url
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

    do {
      return try JSONDecoder().decode(Message.self, from: data)
    } catch {
      print("[Push SDK] - API \(error.localizedDescription)")
      throw error
    }
  }

  static func encryptAndSign(
    messageContent: String, senderPgpPrivateKey: String, publicKeys: [String]
  ) throws -> (String, String, String) {

    let aesKey = getRandomHexString(length: 15)
    let cipherText = try AESCBCHelper.encrypt(messageText: messageContent, secretKey: aesKey)
    let encryptedAES = try Pgp.pgpEncryptV2(
      message: aesKey, pgpPublicKeys: publicKeys)

    let sig = try Pgp.sign(message: cipherText, privateKey: senderPgpPrivateKey)

    return (
      cipherText,
      encryptedAES,
      sig
    )
  }

  static func signMessage(
    messageContent: String, senderPgpPrivateKey: String
  ) throws -> String {

    return try Pgp.sign(message: messageContent, privateKey: senderPgpPrivateKey)
  }

  static func getPrivateGroupSendMessagePayload(
    _ options: SendOptions,
    groupInfo: PushChat
      .PushGroupInfoDTO
  ) async throws
    -> SendMessagePayload
  {

    var encType = "PlainText"
    var (dep_signature, messageConent) = ("", options.messageContent)
    var messageObj = try options.getMessageObjJSON()

    let secretKey = try Pgp.pgpDecrypt(
      cipherText: groupInfo.encryptedSecret!, toPrivateKeyArmored: options.pgpPrivateKey)

    if groupInfo.encryptedSecret != nil {
      // Enc message
      encType = "pgpv1:group"
      messageConent = try AESCBCHelper.encrypt(messageText: messageConent, secretKey: secretKey)
      dep_signature = try Pgp.sign(message: messageConent, privateKey: options.pgpPrivateKey)
      messageObj = try AESCBCHelper.encrypt(messageText: messageObj, secretKey: secretKey)

    } else {
      dep_signature = try signMessage(
        messageContent: messageConent, senderPgpPrivateKey: options.pgpPrivateKey)
    }

    let dataToHash = try getJsonStringFromKV([
      ("fromDID", options.account),
      ("toDID", options.account),
      ("fromCAIP10", options.account),
      ("toCAIP10", options.receiverAddress),
      ("messageObj", messageObj),
      ("messageType", options.messageType.rawValue),
      ("encType", encType),
      ("sessionKey", groupInfo.sessionKey!),
      ("encryptedSecret", "null"),
    ])

    let hash = generateSHA256Hash(msg: dataToHash)
    let verificationProof = try Pgp.sign(message: hash, privateKey: options.pgpPrivateKey)

    return SendMessagePayload(
      fromDID: options.account, toDID: options.receiverAddress,
      fromCAIP10: options.account, toCAIP10: options.receiverAddress,
      messageContent: messageConent,
      messageObj: messageObj,
      messageType: options.messageType.rawValue,
      signature: dep_signature, encType: encType, encryptedSecret: nil, sigType: "pgpv3",
      verificationProof: "pgpv3:\(verificationProof)",
      sessionKey: groupInfo.sessionKey)

  }

  static func getSendMessagePayload(
    _ options: SendOptions, publicKeys: [String], shouldEncrypt: Bool = true
  ) async throws
    -> SendMessagePayload
  {

    var encType = "PlainText"
    var (signature, encryptedSecret, messageConent) = ("", "", options.messageContent)

    if shouldEncrypt {

      encType = "pgp"

      (messageConent, encryptedSecret, signature) = try PushChat.encryptAndSign(
        messageContent: options.messageContent,
        senderPgpPrivateKey: options.pgpPrivateKey,
        publicKeys: publicKeys
      )

    } else {
      signature = try signMessage(
        messageContent: messageConent, senderPgpPrivateKey: options.pgpPrivateKey)
    }

    return SendMessagePayload(
      fromDID: options.account, toDID: options.receiverAddress,
      fromCAIP10: options.account, toCAIP10: options.receiverAddress,
      messageContent: messageConent, messageType: options.messageType.rawValue,
      signature: signature, encType: encType, encryptedSecret: encryptedSecret, sigType: "pgp")
  }

  static func getP2PChatPublicKeys(_ options: SendOptions) async throws -> [String] {
    guard
      let anotherUser = try await PushUser.get(account: options.receiverAddress, env: options.env)
    else {
      throw PushChat.ChatError.userNotFound
    }
    guard let senderUser = try await PushUser.get(account: options.account, env: options.env) else {
      throw PushChat.ChatError.userNotFound
    }
    let publicKeys = [senderUser.getPGPPublickey(), anotherUser.getPGPPublickey()]

    // validate the public keys else return empty
    for pk in publicKeys {
      if !pk.contains("-----BEGIN PGP") {
        return []
      }
    }

    return publicKeys

  }

  static func getGroupChatPublicKeys(_ options: SendOptions) async throws -> [String] {
    if let group = try await PushChat.getGroup(chatId: options.receiverAddress, env: options.env) {
      let isGroupPublic = group.isPublic
      if isGroupPublic {
        return []
      } else {
        let _publicKeys = group.members.compactMap { $0.publicKey }
        return _publicKeys
      }
    } else {
      return []
    }
  }

  static func getAllGroupMembersPublicKeys(_ groupId: String, _ env: ENV) async throws -> [String] {
    if let group = try await PushChat.getGroup(chatId: groupId, env: env) {
      let _publicKeys = group.members.compactMap { $0.publicKey }

      return _publicKeys
    } else {
      return []
    }
  }

  public static func send(_ chatOptions: SendOptions) async throws -> Message {

    let senderAddress = walletToPCAIP10(account: chatOptions.account)
    let receiverAddress = walletToPCAIP10(account: chatOptions.receiverAddress)

    if isGroupChatId(receiverAddress) {
      return try await PushChat.sendMessage(chatOptions)
    }

    let isConversationFirst =
      try await ConversationHash(conversationId: receiverAddress, account: senderAddress) == nil

    if isConversationFirst {
      return try await PushChat.sendIntent(chatOptions)
    } else {
      // send regular message
      return try await PushChat.sendMessage(chatOptions)
    }
  }

  public static func sendMessage(_ sendOptions: SendOptions, enctyptMessage: Bool = true)
    async throws -> Message
  {
    let receiverAddress = walletToPCAIP10(account: sendOptions.receiverAddress)

    var publicKeys: [String] = []
    var shouldEncrypt = enctyptMessage

    if shouldEncrypt {
      if isGroupChatId(receiverAddress) {
        let groupInfo = try await PushChat.getGroupInfoDTO(
          chatId: receiverAddress, env: sendOptions.env)
        if groupInfo.isPublic {
          publicKeys = try await getGroupChatPublicKeys(sendOptions)
        } else {
          let payload = try await getPrivateGroupSendMessagePayload(
            sendOptions, groupInfo: groupInfo)
          return try await sendMessageService(payload: payload, env: sendOptions.env)
        }
      } else {
        publicKeys = try await getP2PChatPublicKeys(sendOptions)
      }

      shouldEncrypt = publicKeys.count > 0 ? true : false
    }

    let sendMessagePayload = try await getSendMessagePayload(
      sendOptions, publicKeys: publicKeys, shouldEncrypt: shouldEncrypt)
    return try await sendMessageService(payload: sendMessagePayload, env: sendOptions.env)
  }

  public static func sendIntent(_ sendOptions: SendOptions) async throws -> Message {
    // check if user exists
    let anotherUser = try await PushUser.get(
      account: sendOptions.receiverAddress, env: sendOptions.env)

    var shouldEncrypt = true

    // else create the user frist and send unencrypted intent message
    if anotherUser == nil || anotherUser?.publicKey == nil {
      let _ = try await PushUser.createUserEmpty(
        userAddress: sendOptions.receiverAddress, env: sendOptions.env)

      shouldEncrypt = false
    }

    let publicKeys = shouldEncrypt ? try await getP2PChatPublicKeys(sendOptions) : []
    let sendMessagePayload = try await getSendMessagePayload(
      sendOptions, publicKeys: publicKeys, shouldEncrypt: shouldEncrypt)

    return try await sendIntentService(payload: sendMessagePayload, env: sendOptions.env)
  }

  static func getApprovePayloadCore(_ approveOptions: ApproveOptions) async throws
    -> ApproveRequestPayload
  {
    if approveOptions.isGroupChat {
      // TODO: remove unwrap
      let groupInfo = try await PushChat.getGroupInfoDTO(
        chatId: approveOptions.toDID, env: approveOptions.env)
      if !groupInfo.isPublic {
        return try await getApprovePayloadPrivateGroup(approveOptions, groupInfo)
      }
    }

    let acceptIntentPayload = try await getApprovePayload(approveOptions)
    return acceptIntentPayload
  }

  public static func approve(_ approveOptions: ApproveOptions) async throws -> String {

    let acceptIntentPayload = try await getApprovePayloadCore(approveOptions)
    let url = try PushEndpoint.acceptChatRequest(env: approveOptions.env).url

    var request = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try JSONEncoder().encode(acceptIntentPayload)

    let (data, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    return try data.toString()
  }

  static func getApprovePayload(_ approveOptions: ApproveOptions) async throws
    -> ApproveRequestPayload
  {
    struct AcceptHashData: Encodable {
      var fromDID: String
      var toDID: String
      var status: String
    }

    let apiData = AcceptHashData(
      fromDID: approveOptions.fromDID,
      toDID: approveOptions.toDID, status: "Approved")

    let jsonString =
      "{\"fromDID\":\"\(apiData.fromDID)\",\"toDID\":\"\(apiData.toDID)\",\"status\":\"\(apiData.status)\"}"
    let hash = generateSHA256Hash(
      msg: jsonString
    )

    let sig = try Pgp.sign(message: hash, privateKey: approveOptions.privateKey)

    return ApproveRequestPayload(
      fromDID: approveOptions.fromDID, toDID: approveOptions.toDID, signature: sig,
      status: "Approved", sigType: "pgp", verificationProof: "pgp:\(sig)")
  }

  static func getApprovePayloadPrivateGroup(
    _ approveOptions: ApproveOptions, _ groupInfo: PushChat.PushGroupInfoDTO
  ) async throws -> ApproveRequestPayload {
    let secretKey = getRandomHexString(length: 15)
    let senderPublicKey = try await PushUser.get(
      account: approveOptions.fromDID, env: approveOptions.env)!.getPGPPublickey()

    var groupMembersPublicKeys = try await getAllGroupMembersPublicKeys(
      groupInfo.chatId, approveOptions.env)
    groupMembersPublicKeys.append(senderPublicKey)

    let encryptedSecret = try Pgp.pgpEncryptV2(
      message: secretKey, pgpPublicKeys: groupMembersPublicKeys)

    // let publicKeys = grou
    let sigType = "pgpv2"

    let bodyToBeHashed = try getJsonStringFromKV([
      ("fromDID", approveOptions.fromDID),
      ("toDID", approveOptions.toDID),
      ("status", "Approved"),
      ("encryptedSecret", encryptedSecret),
    ])

    let hash = generateSHA256Hash(msg: bodyToBeHashed)

    let signature = try Pgp.sign(message: hash, privateKey: approveOptions.privateKey)
    let verificationProof = "\(sigType):\(signature)"

    let approvePayload = ApproveRequestPayload(
      fromDID: approveOptions.fromDID,
      toDID: approveOptions.toDID,
      signature: signature,
      // status: "Approved",
      status: "Approved",
      sigType: sigType,
      verificationProof: verificationProof, encryptedSecret: encryptedSecret
    )

    return approvePayload
  }

  public struct ApproveOptions {
    var fromDID: String
    var toDID: String
    var privateKey: String
    var env: ENV
    var isGroupChat: Bool

    public init(requesterAddress: String, approverAddress: String, privateKey: String, env: ENV) {
      self.fromDID = walletToPCAIP10(account: requesterAddress)
      self.toDID = walletToPCAIP10(account: approverAddress)
      self.privateKey = privateKey
      self.env = env

      self.isGroupChat = isGroupChatId(requesterAddress)

      if isGroupChatId(requesterAddress) {
        self.toDID = walletToPCAIP10(account: requesterAddress)
        self.fromDID = walletToPCAIP10(account: approverAddress)
      }
    }
  }

  struct ApproveRequestPayload: Codable {
    var fromDID: String
    var toDID: String
    var signature: String
    var status: String = "Approved"
    var sigType: String
    var verificationProof: String
    var encryptedSecret: String?
  }

}
