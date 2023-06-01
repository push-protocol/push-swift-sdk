import Push
import XCTest

class SendChatsTests: XCTestCase {

  func testSendIntent() async throws {
    let recipientAddress = generateRandomEthereumAddress()
    let senderAddress = UserAddress
    let senderPgpPk = UserPrivateKey

    let messageToSen = "Hello user \(recipientAddress)"

    let _ = try await Push.Chats.sendIntent(
      Chats.SendOptions(
        messageContent: messageToSen,
        messageType: "Text",
        receiverAddress: recipientAddress,
        account: senderAddress,
        pgpPrivateKey: senderPgpPk
      ))

    let latestFeed = try await Chats.getChats(
      options: GetChatsOptions(
        account: senderAddress, pgpPrivateKey: senderPgpPk, toDecrypt: true, page: 1, limit: 1,
        env: .STAGING))
    let latestMessage = latestFeed[0].msg!.messageContent

    XCTAssertEqual(latestMessage, messageToSen)
  }

  func testSendMessage() async throws {
    let recipientAddress = generateRandomEthereumAddress()
    let senderAddress = UserAddress
    let senderPgpPk = UserPrivateKey

    let messageToSen = "Hello user \(recipientAddress)"

    let _ = try await Push.Chats.sendIntent(
      Chats.SendOptions(
        messageContent: messageToSen,
        messageType: "Text",
        receiverAddress: recipientAddress,
        account: senderAddress,
        pgpPrivateKey: senderPgpPk
      ))

    let _ = try await Push.Chats.sendMessage(
      Chats.SendOptions(
        messageContent: messageToSen,
        messageType: "Text",
        receiverAddress: recipientAddress,
        account: senderAddress,
        pgpPrivateKey: senderPgpPk
      ))

    let latestFeed = try await Chats.getChats(
      options: GetChatsOptions(
        account: senderAddress, pgpPrivateKey: senderPgpPk, toDecrypt: true, page: 1, limit: 1,
        env: .STAGING))
    let latestMessage = latestFeed[0].msg!.messageContent

    XCTAssertEqual(latestMessage, messageToSen)
  }

  func testSend() async throws {
    let recipientAddress = generateRandomEthereumAddress()
    let senderAddress = UserAddress
    let senderPgpPk = UserPrivateKey

    let messageToSen1 = "Hello user --- Intent \(recipientAddress)"
    let messageToSen2 = "Hello user --- Message \(recipientAddress)"

    let _ = try await Push.Chats.send(
      Chats.SendOptions(
        messageContent: messageToSen1,
        messageType: "Text",
        receiverAddress: recipientAddress,
        account: senderAddress,
        pgpPrivateKey: senderPgpPk
      ))

    let latestFeed1 = try await Chats.getChats(
      options: GetChatsOptions(
        account: senderAddress, pgpPrivateKey: senderPgpPk, toDecrypt: true, page: 1, limit: 1,
        env: .STAGING))
    let latestMessage1 = latestFeed1[0].msg!.messageContent

    let _ = try await Push.Chats.send(
      Chats.SendOptions(
        messageContent: messageToSen2,
        messageType: "Text",
        receiverAddress: recipientAddress,
        account: senderAddress,
        pgpPrivateKey: senderPgpPk
      ))

    let latestFeed2 = try await Chats.getChats(
      options: GetChatsOptions(
        account: senderAddress, pgpPrivateKey: senderPgpPk, toDecrypt: true, page: 1, limit: 1,
        env: .STAGING))
    let latestMessage2 = latestFeed2[0].msg!.messageContent

    XCTAssertEqual(latestMessage1, messageToSen1)
    XCTAssertEqual(latestMessage2, messageToSen2)
  }

}

let UserAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"

let UserPrivateKey = """
  -----BEGIN PGP PRIVATE KEY BLOCK-----
  Version: openpgp-mobile

  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
  =aUD6
  -----END PGP PRIVATE KEY BLOCK-----
  """
