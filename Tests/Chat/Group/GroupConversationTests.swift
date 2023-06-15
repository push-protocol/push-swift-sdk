import Push
import XCTest

class GroupChatConversationTests: XCTestCase {

  func testGroupConversationHash() async throws {
    let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
    let groupId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"

    let converationHash = try await PushChat.ConversationHash(
      conversationId: groupId, account: userAddress)!

    // For empty conversation return nil
    let converationHashNil = try await PushChat.ConversationHash(
      conversationId: "fffff7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6",
      account: userAddress)

    XCTAssertEqual(converationHash.count, 59)
    XCTAssertEqual(converationHashNil, nil)

  }

}
