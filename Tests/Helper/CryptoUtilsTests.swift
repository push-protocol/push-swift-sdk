import Push
import XCTest

class CryptoUtilTests: XCTestCase {

  func testRandomHexString() async throws {
    let m1 = getRandomHexString(length: 10)
    let m2 = getRandomHexString(length: 10)
    let m3 = getRandomHexString(length: 15)

    XCTAssertEqual(m1.count, 10 * 2)
    XCTAssertEqual(m2.count, 10 * 2)
    XCTAssertEqual(m3.count, 15 * 2)

    XCTAssertNotEqual(m1, m2)
  }

  func testHash() async throws {
    let message = "Enable Push Chat"
    let hash = generateSHA256Hash(msg: message)

    XCTAssertEqual(
      hash,
      "c8c6f04fa48423eea0d8b70eaa63e55d6803cb1318a01461746b192505663fab"
    )
  }

}
