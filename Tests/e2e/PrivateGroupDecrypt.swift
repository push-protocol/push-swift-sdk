import Push
import XCTest

class PrivateGroupDerypt: XCTestCase {

  func testPrivateGroupFetchConvesation() async throws {
    let env = ENV.STAGING
    let chatId = "fc59213b81c37dd877476783b36357a4b322c50dc2c4d16af2c4d3480e3f5f2d"
    let groupSessionKey = try await PushChat.getGroupSessionKey(chatId: chatId, env: env)

    print("got the sessionKey \(groupSessionKey)")
  }
}
