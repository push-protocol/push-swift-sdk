import Push
import XCTest

class AddressHelperTests: XCTestCase {

  func testIsValidEthAddress() async throws {
    let validAddress1 = "0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE"
    let validAddress2 = "eip155:0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE"
    let validAddress3 = "eip155:1:0x5AEDA56215b167893e80B4fE645BA6d5Bab767DE"

    XCTAssert(
      Push.isValidETHAddress(address: validAddress1),
      "\(validAddress1) expected to be valid address")
    XCTAssert(
      Push.isValidETHAddress(address: validAddress2),
      "\(validAddress2) expected to be valid address")
    XCTAssert(
      Push.isValidETHAddress(address: validAddress3),
      "\(validAddress3) expected to be valid address")

    // let inValidAddress1 = "0x6AEDA56215b167893e80B4fE645BA6d5Bab767DE"
    // let inValidAddress2 = "eip155:0x6AEDA56215b167893e80B4fE645BA6d5Bab767DE"
    // let inValidAddress3 = "eip155:1:0x6AEDA56215b167893e80B4fE645BA6d5Bab767DE"

    // XCTAssertFalse(
    //   Push.isValidETHAddress(address: inValidAddress1),
    //   "\(inValidAddress1) expected to be valid address")
    // XCTAssertFalse(
    //   Push.isValidETHAddress(address: inValidAddress2),
    //   "\(inValidAddress2) expected to be valid address")
    // XCTAssertFalse(
    //   Push.isValidETHAddress(address: inValidAddress3),
    //   "\(inValidAddress3) expected to be valid address")

  }

}
