import Push
import XCTest

class GetChatsTests: XCTestCase {

  func testGetChatsFeeds() async throws {
    let signer = try SignerPrivateKey(
      privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
    let userAddress = try await signer.getAddress()

    let user = try await PushUser.get(account: userAddress, env: .STAGING)!
    let pgpPrivateKey = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)

    let chats = try await Push.PushChat.getChats(
      options: GetChatsOptions(
        account: userAddress,
        pgpPrivateKey: pgpPrivateKey,
        toDecrypt: true,
        limit: 5,
        env: ENV.STAGING
      ))

    for chat in chats {
      let message = chat.msg?.messageContent
      XCTAssert(message != nil)
    }
  }

  func testChatHistory() async throws {
    // import Foundation
    let signer = try SignerPrivateKey(
      privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
    let userAddress = try await signer.getAddress()
    let user = try await PushUser.get(account: userAddress, env: .STAGING)!
    let pgpPrivateKey = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)

    let converationHash = try await PushChat.ConversationHash(
      conversationId: "0x4D5bE92D510300ceF50a2FC03534A95b60028950", account: userAddress)!

    let messages = try await PushChat.History(
      threadHash: converationHash, limit: 5, pgpPrivateKey: pgpPrivateKey, env: .STAGING)

    for msg in messages {
      XCTAssert(msg.messageContent.count > 0)
    }
  }

}
