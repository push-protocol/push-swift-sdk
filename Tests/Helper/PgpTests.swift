import Push
import XCTest

class PgpTests: XCTestCase {

  func testPgpPairGenration() async throws {
    let pair = try Push.Pgp.GenerateNewPgpPair()
    let msg = "Create Push Profile \n" + Push.generateSHA256Hash(msg: pair.getPublicKey())

    // let { verificationProof } = await getEip191Signature(
    //     wallet,
    //     createProfileMessage
    //   );

    print(msg)
    XCTAssert(pair.getPublicKey().count > 0, "Public key is empty")
    XCTAssert(pair.getSecretKey().count > 0, "Secret key is empty")
    // XCTAssert(1 == 2)
  }

}
