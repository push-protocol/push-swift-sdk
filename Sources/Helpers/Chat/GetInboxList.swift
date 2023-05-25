import Foundation
import ObjectivePGP

struct BodyToHashInboxList: Encodable {
  let fromDID: String
  let toDID: String
  let messageContent: String
  let messageType: String
}

func verifySignature(messageContent: String, signatureArmored: String, publicKeyArmored: String) throws {
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
    let secretKey: String = try Pgp.pgpDecrypt(cipherText: encryptedSecretKey, toPrivateKeyArmored: privateKeyArmored);
    if(message.link == nil) {
      let bodyToBeHashed = BodyToHashInboxList(
        fromDID: message.fromDID,
        toDID: message.toDID,
        messageContent: message.messageContent,
        messageType: message.messageType
      );
      let hash = generateSHA256Hash(msg: String(data: try JSONEncoder().encode(bodyToBeHashed), encoding: .utf8) ?? "");
      do {
        try verifySignature(
          messageContent: hash,
          signatureArmored: signatureArmored,
          publicKeyArmored: publicKeyArmored
        );
      } catch {
        try verifySignature(
          messageContent: cipherText,
          signatureArmored: signatureArmored,
          publicKeyArmored: publicKeyArmored
        );
      }
    } else {
      try verifySignature(
        messageContent: cipherText,
        signatureArmored: signatureArmored,
        publicKeyArmored: publicKeyArmored
      );
    }
    return try AESHelper.decrypt(cipherText: cipherText, secretKey: secretKey);
  } catch {
    return "Unable to decrypt message";
  }
}


private func decryptFeeds(
  feeds: [Feeds],
  connectedUser: User,
  pgpPrivateKey: String?,
  env: ENV
  ) async throws -> [Feeds] {
  var otherPeer: User?;
  var signatureValidationPubliKey: String = "";
  var updatedFeeds: [Feeds] = [];
  for feed in feeds {
    var gotOtherPeer = false;
    var currentFeed = feed;
    if(currentFeed.msg == nil) {
      updatedFeeds.append(currentFeed);
      continue;
    }
    if(currentFeed.msg!.encType != "PlainText") {
      if(pgpPrivateKey == nil) {
        throw ChatError.decryptedPrivateKeyNecessary;
      }
      if(currentFeed.msg!.fromCAIP10 != connectedUser.wallets.split(separator: ",")[0]) {
        if(!gotOtherPeer) {
          otherPeer = try await User.get(account: currentFeed.msg!.fromCAIP10, env: env);
          gotOtherPeer = true;
        }
        signatureValidationPubliKey = otherPeer!.publicKey;
      } else {
        signatureValidationPubliKey = connectedUser.publicKey;
      }
      currentFeed.msg!.messageContent = try await decryptAndVerifySignature(
        cipherText: currentFeed.msg!.messageContent,
        encryptedSecretKey: currentFeed.msg!.encryptedSecret,
        publicKeyArmored: signatureValidationPubliKey,
        signatureArmored: currentFeed.msg!.signature,
        privateKeyArmored: pgpPrivateKey!,
        message: currentFeed.msg!
      );
    }
    updatedFeeds.append(currentFeed);
  }
  return updatedFeeds;
}

public func getInboxLists(
  chats: [Feeds],
  user: String,
  toDecrypt: Bool,
  pgpPrivateKey: String?,
  env: ENV
) async throws -> [Feeds] {
  let connectedUser = try await User.get(account: user, env: env);
  if(connectedUser == nil) {
    throw ChatError.invalidAddress;
  }
  var feeds: [Feeds] = [];
  for list in chats {
    var message: Message;
    print("getting message: \(list)")
    
    if(list.threadhash != nil) {
      message = try await getCID(env: env, cid: list.threadhash!);
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
      );
    }
    feeds.append(
      Feeds(
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
    );
  }

  if(toDecrypt) {
    return try await decryptFeeds(
      feeds: feeds,
      connectedUser: connectedUser!,
      pgpPrivateKey: pgpPrivateKey,
      env: env
    );
  }
  return feeds;
}