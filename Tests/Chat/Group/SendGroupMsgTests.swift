import Push
import XCTest

class GroupChatSendMsgTests: XCTestCase {

  func testGroupSendMsg() async throws {
    let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
    let groupId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    let randomMessage = "Hello \(generateRandomEthereumAddress())"
    
    let _ = try await Push.PushChat.sendMessage(
      PushChat.SendOptions(
        messageContent: randomMessage,
        messageType: "Text",
        receiverAddress: groupId,
        account: userAddress,
        pgpPrivateKey: UserPrivateKey
      ))

  }

}
