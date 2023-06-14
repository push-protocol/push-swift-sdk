import Push
import XCTest

class GetGroupTest: XCTestCase {

  func testGetExistingGroupChat() async throws {
    let chatId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    let group = try await PushChat.getGroup(chatId: chatId, env: .STAGING)!

    XCTAssertEqual(group.chatId, chatId)
    XCTAssert(group.groupCreator.count > 0)
  }

  func testGetNonExistingGroupChat() async throws {
    let chatId = "065ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    let group = try await PushChat.getGroup(chatId: chatId, env: .STAGING)

    XCTAssert(group == nil)
  }

}
