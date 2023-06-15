import Push
import XCTest

class GroupChatSendMsgTests: XCTestCase {

  func testPublicGroupSendMsg() async throws {
    let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
    let groupId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    let randomMessage = "Hello \(generateRandomEthereumAddress())"

    let msgRes = try await Push.PushChat.send(
      PushChat.SendOptions(
        messageContent: randomMessage,
        messageType: "Text",
        receiverAddress: groupId,
        account: userAddress,
        pgpPrivateKey: UserPrivateKey
      ))

    XCTAssertEqual(msgRes.encType, "PlainText")
    XCTAssertEqual(msgRes.messageContent, randomMessage)
  }

  func testPrivateGroupSendMsg() async throws {
    let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
    let groupId = "8fe92fe913370a0bde2777dc543d0668de6c0bb9cee9f71d0d10da962d50f6c3"
    let randomMessage = "Hello \(generateRandomEthereumAddress())"

    let msgRes = try await Push.PushChat.send(
      PushChat.SendOptions(
        messageContent: randomMessage,
        messageType: "Text",
        receiverAddress: groupId,
        account: userAddress,
        pgpPrivateKey: UserPrivateKey
      ))

    let decrytedMessage = try PushChat.decryptMessage(
      message: msgRes, privateKeyArmored: UserPrivateKey)

    XCTAssertEqual(msgRes.encType, "pgp")
    XCTAssertEqual(decrytedMessage, randomMessage)
  }

}
