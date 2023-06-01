import Foundation

extension Chats {
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

  static func getSendMessagePayload(_ options: SendOptions, shouldEncrypt: Bool = true) async throws
    -> SendMessagePayload
  {
    if !shouldEncrypt {
      return SendMessagePayload(
        fromDID: options.account, toDID: options.receiverAddress,
        fromCAIP10: options.account, toCAIP10: options.receiverAddress,
        messageContent: options.messageContent, messageType: options.messageType,
        signature: "", encType: "PlainText", encryptedSecret: "", sigType: "pgp")
    }

    return SendMessagePayload(
      fromDID: options.account, toDID: options.receiverAddress,
      fromCAIP10: options.account, toCAIP10: options.receiverAddress,
      messageContent: options.messageContent, messageType: options.messageType,
      signature: "", encType: "PlainText", encryptedSecret: "", sigType: "pgp")
  }

  public static func send(_ chatOptions: SendOptions) async throws -> Message {
    let senderAddress = walletToPCAIP10(account: chatOptions.account)
    let receiverAddress = walletToPCAIP10(account: chatOptions.receiverAddress)

    let isConversationFirst =
      try await ConversationHash(conversationId: receiverAddress, account: senderAddress) == nil

    if isConversationFirst {
      return try await Chats.sendIntent(chatOptions)
    } else {
      // send regular message
      return try await Chats.sendMessage(chatOptions)
    }
  }

  public static func sendMessage(_ sendOptions: SendOptions) async throws -> Message {
    let enctyptMessage = false

    let sendMessagePayload = try await getSendMessagePayload(
      sendOptions, shouldEncrypt: enctyptMessage)
    return try await sendMessageService(payload: sendMessagePayload, env: sendOptions.env)
  }

  public static func sendIntent(_ sendOptions: SendOptions) async throws -> Message {
    // check if user exists
    let anotherUser = try await User.get(account: sendOptions.receiverAddress, env: .STAGING)

    // else create the user frist and send unencrypted intent message
    var enctyptMessage = true

    if anotherUser == nil {
      let _ = try await User.createUserEmpty(
        userAddress: sendOptions.receiverAddress, env: sendOptions.env)
      enctyptMessage = false
    }

    // if anotherUser == nil {
    //   let _ = try await User.createUserEmpty(
    //     userAddress: sendOptions.receiverAddress, env: sendOptions.env)
    //   enctyptMessage = false
    // } else {
    //   if anotherUser!.publicKey.count == 0 {
    //     enctyptMessage = false
    //   }
    // }
    // if enctyptMessage {
    //   let anotherUserPublicKey = anotherUser!.publicKey
    // }

    let sendMessagePayload = try await getSendMessagePayload(
      sendOptions, shouldEncrypt: enctyptMessage)
    return try await sendIntentService(payload: sendMessagePayload, env: sendOptions.env)
  }

}

// let bodyToBeHashed = "{\"fromDID\":\"\(sendOptions.account)\",\"toDID\":\"\(sendOptions.receiverAddress)\",\"messageContent\":\"\(sendOptions.messageContent)\",\"messageType\":\"\(sendOptions.messageType)\"}"
//let messageHash = generateSHA256Hash(msg: bodyToBeHashed)
