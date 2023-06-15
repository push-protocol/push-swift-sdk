import Push
import XCTest

class ConversationTests: XCTestCase {

  func testConversationHash() async throws {
    let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
    let converationHash = try await PushChat.ConversationHash(
      conversationId: "0xACEe0D180d0118FD4F3027Ab801cc862520570d1", account: userAddress)!

    // For empty conversation return nil
    let converationHashNil = try await PushChat.ConversationHash(
      conversationId: "0xACFe0D180d0118FD4F3027Ab801cc862520570d1", account: userAddress)

    XCTAssertEqual(converationHash.count, 59)
    XCTAssertEqual(converationHashNil, nil)

  }
}
