import Push
import XCTest

class SignerTests: XCTestCase {
  func getWallet(signer: Push.Signer) async throws -> Push.Wallet {
    return try await Push.Wallet(signer: signer)
  }

  func testSignerCanDoEIP191Sig() async throws {
    let signer = try SignerPrivateKey(
      privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")

    let msg =
      "Create Push Profile \n252f10c83610ebca1a059c0bae8255eba2f95be4d1d7bcfa89d7248a82d9f111"
    let sig = try await signer.getEip191Signature(message: msg)

    XCTAssertEqual(
      sig,
      "0x9d71faa2582414160f3bc5b62bd8204b45e8ce60e42e034065366c27ed4f456d406ed157fec97db7cedb070f3488a0e78b6b59467063fab11aee6a2bf8233b131b"
    )
  }

  func testSignerCanDoEIP191SigV2() async throws {
    let signer = try SignerPrivateKey(
      privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
    let msg =
      "Create Push Profile \n252f10c83610ebca1a059c0bae8255eba2f95be4d1d7bcfa89d7248a82d9f111"

    let wallet = try await getWallet(signer: signer)
    let sig = try await wallet.getEip191Signature(message: msg, version: "v2")

    XCTAssertEqual(
      sig,
      "eip191v2:0x9d71faa2582414160f3bc5b62bd8204b45e8ce60e42e034065366c27ed4f456d406ed157fec97db7cedb070f3488a0e78b6b59467063fab11aee6a2bf8233b131b"
    )
  }

  func testSignerDerivesAesSecret() async throws {
    let preKey = "c6f086dbc8295c8499873bf73e374f0bc230d567705c047938b3414163132280"
    let signer = try SignerPrivateKey(
      privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
    let msg =
      "Enable Push Profile \n\(preKey)"

    let wallet = try await getWallet(signer: signer)
    let secret = try await wallet.getEip191Signature(message: msg, version: "v1")
    let expected =
      "eip191:0x79725b6918f31cf01da680c8c11c8c6a208130c35459d64032444b7ba6b3b2cc447671d6c3be264fdfa08d5114cead9ca383f683809ec69f3c70c7101fc253221c"

    XCTAssertEqual(
      secret,
      expected
    )
  }

}
