import Push
import Web3
import XCTest

class PgpTests: XCTestCase {

  func testPgpPairGenration() async throws {
    let pair = try Push.Pgp.GenerateNewPgpPair()

    XCTAssert(pair.getPublicKey().count > 0, "Public key is empty")
    XCTAssert(pair.getSecretKey().count > 0, "Secret key is empty")
  }

}
