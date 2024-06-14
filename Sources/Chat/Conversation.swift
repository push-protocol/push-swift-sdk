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
          let (decryptedMsg, decryptedObj) = try await decryptMessage(
            message: messages[i], privateKeyArmored: pgpPrivateKey, env: env)

          if decryptedObj != nil {
            messages[i].messageObj = MessageObj(content: decryptedObj)
          }
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
    privateKeyArmored: String,
    env: ENV = ENV.STAGING
  ) async throws -> (String, String?) {
    do {

      if message.encType == "pgpv1:group" {
        return try await decryptPrivateGroupMessage(
          message, privateKeyArmored: privateKeyArmored, env: env)
      }
      if message.encType != "pgp" {
        return (message.messageContent, nil)
      }
      let decrypytedMessage = try decryptMessage(
        message.messageContent, encryptedSecret: message.encryptedSecret!,
        privateKeyArmored: privateKeyArmored)

      return (decrypytedMessage, nil)
    } catch {
      if isGroupChatId(message.toCAIP10) {
        return ("message encrypted before you join", nil)
      }
      return ("Unable to decrypt message", nil)
    }
  }

  public static func decryptPrivateGroupMessage(
    _ message: Message,
    privateKeyArmored: String,
    groupSecretKey: String? = nil,
    env: ENV
  ) async throws -> (String, String?) {
    do {
        let secretKey: String
        if let groupSecretKey {
            secretKey = groupSecretKey
        } else {
            secretKey = try await getPrivateGroupPGPSecretKey(
                sessionKey: message.sessionKey!,
                privateKeyArmored: privateKeyArmored,
                env: env)
        }
        
        return try decryptPrivateGroupMessage(message, using: secretKey, privateKeyArmored: privateKeyArmored, env: env)
    } catch {
      throw PushChat.ChatError.dectyptionFalied
    }
  }

    public static func getPrivateGroupPGPSecretKey(
        sessionKey: String,
        privateKeyArmored: String,
        env: ENV
    ) async throws -> String {
        let encryptedSecret = try await PushChat.getGroupSessionKey(
            sessionKey: sessionKey, env: env)
        return try decryptPGPSecretKey(
            encryptedSecret: encryptedSecret, toPrivateKeyArmored: privateKeyArmored)
    }
    
    public static func decryptPrivateGroupMessage(
        _ message: Message,
        using secretKey: String,
        privateKeyArmored: String,
        env: ENV
    ) throws -> (String, String?) {
        do {
            var messageObj: String? = nil
            if let msgObj = message.messageObj {
                messageObj = try? decryptMessage(
                    msgObj.content!, secretKey: secretKey)
            }
            
            let decMsg = try decryptMessage(
                message.messageContent,
                secretKey: secretKey)
            
            return (decMsg, messageObj)
        } catch {
            throw PushChat.ChatError.dectyptionFalied
        }
    }
    
    public static func decryptMessage(
        _ message: String,
        encryptedSecret: String,
        privateKeyArmored: String
    ) throws -> String {
        do {
            
            let secretKey = try decryptPGPSecretKey(
                encryptedSecret: encryptedSecret, toPrivateKeyArmored: privateKeyArmored)
            
            return try decryptMessage(message, secretKey: secretKey)
        } catch {
            throw PushChat.ChatError.dectyptionFalied
        }
    }
    
    public static func decryptPGPSecretKey(
        encryptedSecret: String,
        toPrivateKeyArmored privateKeyArmored: String
    ) throws -> String {
        try Pgp.pgpDecrypt(
            cipherText: encryptedSecret, toPrivateKeyArmored: privateKeyArmored)
    }
    
    public static func decryptMessage(
        _ message: String,
        secretKey: String
    ) throws -> String {
        do {
            guard let userMsg = try AESCBCHelper.decrypt(cipherText: message, secretKey: secretKey) else {
                throw PushChat.ChatError.dectyptionFalied
            }
            
            if let userMsgStr = String(data: userMsg, encoding: .utf8) {
                return userMsgStr
            }
            throw PushChat.ChatError.dectyptionFalied
        } catch {
            throw PushChat.ChatError.dectyptionFalied
        }
    }
    
}
