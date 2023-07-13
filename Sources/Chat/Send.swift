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
    var messageType: String
    var signature: String
    var encType: String
    var encryptedSecret: String
    var sigType: String
    var verificationProof: String?
  }

  public struct SendOptions {
    public var messageContent = ""
    public var messageType = "Text"
    public var receiverAddress: String
    public var account: String
    public var pgpPrivateKey: String
    public var senderPgpPubicKey: String?
    public var receiverPgpPubicKey: String?
    public var env: ENV = .STAGING

    public init(
      messageContent: String, messageType: String, receiverAddress: String, account: String,
      pgpPrivateKey: String, env: ENV = .STAGING
    ) {
      self.messageContent = messageContent
      self.messageType = messageType
      self.receiverAddress = walletToPCAIP10(account: receiverAddress)
      self.account = walletToPCAIP10(account: account)
      self.pgpPrivateKey = pgpPrivateKey
      self.env = env
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
      messageContent: messageConent, messageType: options.messageType,
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
        publicKeys = try await getGroupChatPublicKeys(sendOptions)
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

    // else create the user frist and send unencrypted intent message
    if anotherUser == nil {
      let _ = try await PushUser.createUserEmpty(
        userAddress: sendOptions.receiverAddress, env: sendOptions.env)
    }

    let sendMessagePayload = try await getSendMessagePayload(
      sendOptions, publicKeys: [], shouldEncrypt: false)

    return try await sendIntentService(payload: sendMessagePayload, env: sendOptions.env)
  }

  public static func approve(_ approveOptions: ApproveOptions) async throws -> String {
    let acceptIntentPayload = try await getApprovePayload(approveOptions)

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

    let jsonString = try JSONEncoder().encode(apiData).toString()
    let hash = generateSHA256Hash(
      msg: jsonString
    )

    let sig = try Pgp.sign(message: hash, privateKey: approveOptions.privateKey)

    return ApproveRequestPayload(
      fromDID: approveOptions.fromDID, toDID: approveOptions.toDID, signature: sig,
      status: "Approved", sigType: "pgp", verificationProof: "pgp:\(sig)")
  }

  public struct ApproveOptions {
    var fromDID: String
    var toDID: String
    var privateKey: String
    var env: ENV

    public init(requesterAddress: String, approverAddress: String, privateKey: String, env: ENV) {
      self.fromDID = walletToPCAIP10(account: requesterAddress)
      self.toDID = walletToPCAIP10(account: approverAddress)
      self.privateKey = privateKey
      self.env = env

      if(isGroupChatId(requesterAddress)){
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
  }

}
