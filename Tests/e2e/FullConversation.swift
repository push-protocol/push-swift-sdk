import Push
import XCTest

class FullConversation: XCTestCase {

  func testFullConvesation() async throws {

    let userPk1 = getRandomAccount()
    let userPk2 = getRandomAccount()

    let signer1 = try SignerPrivateKey(privateKey: userPk1)
    let signer2 = try SignerPrivateKey(privateKey: userPk2)

    let address1 = try await signer1.getAddress()
    let address2 = try await signer2.getAddress()

    let user1 = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: SignerPrivateKey(
          privateKey: userPk1
        ),
        progressHook: nil
      ))

    let user2 = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: SignerPrivateKey(
          privateKey: userPk2
        ),
        progressHook: nil
      ))

    let user1PpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user1.encryptedPrivateKey, signer: signer1)
    let user2PpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user2.encryptedPrivateKey, signer: signer2)

    // user 1 sends intent to user 2
    let messageToSen = "Hello user \(address1)"
    let _ = try await Push.PushChat.sendIntent(
      PushChat.SendOptions(
        messageContent: messageToSen,
        messageType: "Text",
        receiverAddress: address2,
        account: address1,
        pgpPrivateKey: user1PpgpPk
      ))

    // user 2 accepts the intent
    let _ = try await Push.PushChat.approve(
      PushChat.ApproveOptions(
        requesterAddress: address1, approverAddress: address2, privateKey: user2PpgpPk,
        env: .STAGING))

    // they con chat now
    let msg1 = "Ping"
    let msg2 = "Ping"
    let _ = try await Push.PushChat.send(
      PushChat.SendOptions(
        messageContent: msg1,
        messageType: "Text",
        receiverAddress: address2,
        account: address1,
        pgpPrivateKey: user1PpgpPk
      ))

    let _ = try await Push.PushChat.send(
      PushChat.SendOptions(
        messageContent: msg2,
        messageType: "Text",
        receiverAddress: address1,
        account: address2,
        pgpPrivateKey: user2PpgpPk
      ))

    // check message
    let converationHash1 = try await PushChat.ConversationHash(
      conversationId: address1, account: address2)!

    let messages1 = try await PushChat.History(
      threadHash: converationHash1, limit: 2, pgpPrivateKey: user1PpgpPk, toDecrypt: true,
      env: .STAGING)

    let msg1_1 = messages1[0].messageContent
    let msg1_2 = messages1[1].messageContent

    let converationHash2 = try await PushChat.ConversationHash(
      conversationId: address1, account: address2)!

    let messages2 = try await PushChat.History(
      threadHash: converationHash2, limit: 2, pgpPrivateKey: user2PpgpPk, toDecrypt: true,
      env: .STAGING)

    let msg2_1 = messages2[0].messageContent
    let msg2_2 = messages2[1].messageContent

    XCTAssertEqual(msg1_1, msg2_1)
    XCTAssertEqual(msg1_1, msg1)

    XCTAssertEqual(msg1_2, msg2_2)
    XCTAssertEqual(msg1_2, msg2)
  }
}
