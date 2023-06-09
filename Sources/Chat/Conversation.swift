import Foundation

extension PushChat {
  struct Hash: Codable { var threadHash: String? }

  public static func ConversationHash(
    conversationId: String,
    account: String,
    env: ENV = ENV.STAGING
  ) async throws -> String? {
    let conversationIdCAIP = walletToPCAIP10(account: conversationId)
    let accountCAIP = walletToPCAIP10(account: account)

    let url = try PushEndpoint.getConversationHash(
      converationId: conversationIdCAIP, account: accountCAIP, env: env
    ).url

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let hashStruct = try JSONDecoder().decode(Hash.self, from: data)
      return hashStruct.threadHash
    } catch {
      print("error: \(error)")
      throw error
    }
  }

  public static func Latest(threadHash: String, pgpPrivateKey: String, toDecrypt: Bool, env: ENV)
    async throws
    -> Message
  {
    return try await History(
      threadHash: threadHash, limit: 1, pgpPrivateKey: pgpPrivateKey, toDecrypt: toDecrypt, env: env
    ).first!
  }

  public static func History(
    threadHash: String, limit: Int, pgpPrivateKey: String, toDecrypt: Bool, env: ENV
  )
    async throws -> [Message]
  {
    do {
      var messages = try await getMessagesService(threadHash: threadHash, limit: limit, env: env)

      if toDecrypt {
        for i in 0..<messages.count {
          let decryptedMsg = try decryptMessage(
            message: messages[i], privateKeyArmored: pgpPrivateKey)
          messages[i].messageContent = decryptedMsg
        }
      }

      return messages
    } catch {
      print("error: \(error)")
      throw error
    }

  }

  static func getMessagesService(threadHash: String, limit: Int = 1, env: ENV) async throws
    -> [Message]
  {
    let url = try PushEndpoint.getConversationHashReslove(
      threadHash: threadHash, fetchLimit: limit, env: env
    ).url

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let messages = try JSONDecoder().decode([Message].self, from: data)
      return messages
    } catch {
      print("error: \(error)")
      throw error
    }
  }

  public static func decryptMessage(
    message: Message,
    privateKeyArmored: String
  ) throws -> String {
    do {
      if message.encType != "pgp" {
        return message.messageContent
      }
      return try decryptMessage(
        message.messageContent, encryptedSecret: message.encryptedSecret,
        privateKeyArmored: privateKeyArmored)
    } catch {
      return "Unable to decrypt message"
    }
  }

  public static func decryptMessage(
    _ message: String,
    encryptedSecret: String,
    privateKeyArmored: String
  ) throws -> String {
    do {

      let secretKey = try Pgp.pgpDecrypt(
        cipherText: encryptedSecret, toPrivateKeyArmored: privateKeyArmored)

      let userMsg = AESCBCHelper.decrypt(cipherText: message, secretKey: secretKey)!
      let userMsgStr = String(data: userMsg, encoding: .utf8)

      if userMsgStr == nil {
        return "Unable to decrypt message"
      }

      return userMsgStr!
    } catch {
      return "Unable to decrypt message"
    }
  }
}
