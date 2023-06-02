import Push
import XCTest

class GetFeedsTests: XCTestCase {

  func testUserFeedsReturns() async throws {
    let user = "eip155:0x3aae65DF8424b0Bb80C1f74dD480b04dbEA54213"

    let res = try await PushUser.getFeeds(
      options:
        PushUser.FeedsOptionsType(
          user: user,
          env: ENV.STAGING
        )
    )

    XCTAssertNotNil(res, "res should not be nil")
  }

  func testUserFeedsReturnWhenInvalidAddress() async throws {
    let user = "eip155:0x3aae65DF8424b0B"
    let expectation = XCTestExpectation(description: "Throws error")
    do {
      let _ = try await PushUser.getFeeds(
        options:
          PushUser.FeedsOptionsType(
            user: user,
            env: ENV.STAGING
          )
      )
    } catch {
      expectation.fulfill()
    }
    await XCTWaiter().fulfillment(of: [expectation], timeout: 5.0, enforceOrder: true)
  }
}
