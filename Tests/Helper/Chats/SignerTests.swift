import Push
import XCTest

class SignerTests: XCTestCase {

  func testSignerCanDoEIP191Sig() async throws {
    let signer = Push.Singer(privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
    let msg = "Create Push Profile \n252f10c83610ebca1a059c0bae8255eba2f95be4d1d7bcfa89d7248a82d9f111"
    let sig = try signer.getEip191Signature(message: msg)

    XCTAssertEqual(
        sig,
        "0x9d71faa2582414160f3bc5b62bd8204b45e8ce60e42e034065366c27ed4f456d406ed157fec97db7cedb070f3488a0e78b6b59467063fab11aee6a2bf8233b131b"
    )
  }

}
