import Foundation
import ObjectivePGP

struct BodyToHashInboxList: Encodable {
  let fromDID: String
  let toDID: String
  let messageContent: String
  let messageType: String
}

func verifySignature(messageContent: String, signatureArmored: String, publicKeyArmored: String)
  throws
{
  // TODO: Implement
}

private func decryptAndVerifySignature(
  cipherText: String,
  encryptedSecretKey: String,
  publicKeyArmored: String,
  signatureArmored: String,
  privateKeyArmored: String,
  message: Message
) async throws -> String {
  do {
    print("doing")
    let secretKey: String = try Pgp.pgpDecrypt(
      cipherText: encryptedSecretKey, toPrivateKeyArmored: privateKeyArmored)

    print("doing")
    let userMsg = AESCBCHelper.decrypt(cipherText: cipherText, secretKey: secretKey)!
    print("doing")
    let userMsgStr = String(data: userMsg, encoding: .utf8)!
    print("User", userMsg)
    return userMsgStr
  } catch {
    return "Abishek Unable to decrypt message \(error)"
  }
}

private func decryptFeeds(
  feeds: [PushChat.Feeds],
  connectedUser: PushUser,
  pgpPrivateKey: String?,
  env: ENV
) async throws -> [PushChat.Feeds] {
  var updatedFeeds: [PushChat.Feeds] = []
  for feed in feeds {
    var currentFeed = feed
    // print(feed.chatId, feed.publicKey?.count, feed.msg?.encType)
    if currentFeed.msg == nil {
      updatedFeeds.append(currentFeed)
      continue
    }
    if currentFeed.msg!.encType == "pgp" {
      if pgpPrivateKey == nil {
        throw PushChat.ChatError.decryptedPrivateKeyNecessary
      }

      let decryptedMsg = try PushChat.decryptMessage(
        message: currentFeed.msg!, privateKeyArmored: pgpPrivateKey!)
      currentFeed.msg?.messageContent = decryptedMsg
    }
    updatedFeeds.append(currentFeed)
  }
  return updatedFeeds
}

public func getInboxLists(
  chats: [PushChat.Feeds],
  user: String,
  toDecrypt: Bool,
  pgpPrivateKey: String?,
  env: ENV
) async throws -> [PushChat.Feeds] {
  let connectedUser = try await PushUser.get(account: user, env: env)
  if connectedUser == nil {
    throw PushChat.ChatError.invalidAddress
  }
  var feeds: [PushChat.Feeds] = []
  for list in chats {
    var message: Message

    if list.threadhash != nil {
      message = try await getCID(env: env, cid: list.threadhash!)
    } else {
      message = Message(
        fromCAIP10: "",
        toCAIP10: "",
        fromDID: "",
        toDID: "",
        messageType: "",
        messageContent: "",
        signature: "",
        sigType: "",
        timestamp: nil,
        encType: "PlainText",
        encryptedSecret: "",
        link: ""
      )
    }
    feeds.append(
      PushChat.Feeds(
        msg: message,
        did: list.did,
        wallets: list.wallets,
        profilePicture: list.profilePicture,
        publicKey: list.publicKey,
        about: list.about,
        threadhash: list.threadhash,
        intent: list.intent,
        intentSentBy: list.intentSentBy,
        intentTimestamp: list.intentTimestamp,
        combinedDID: list.combinedDID,
        cid: list.cid,
        chatId: list.chatId,
        deprecated: list.deprecated,
        deprecatedCode: list.deprecatedCode
      )
    )
  }

  if toDecrypt {
    return try await decryptFeeds(
      feeds: feeds,
      connectedUser: connectedUser!,
      pgpPrivateKey: pgpPrivateKey,
      env: env
    )
  }
  return feeds
}
