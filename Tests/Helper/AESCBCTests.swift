import Push
import XCTest

class AESCBC: XCTestCase {

  func testAESDecrypt() async throws {
    let ciphertextOriginal = "U2FsdGVkX18/SWOonW/UfODCpIrRFuOUKITIvRob3iE="
    let key = "XxJNyUTlCFrrbTG"

    let originalMsg = AESCBCHelper.decrypt(cipherText: ciphertextOriginal, secretKey: key)!
    let msg = String(data: originalMsg, encoding: .utf8)

    XCTAssertEqual(msg, "pong")
  }

  func testAESEncrypt() async throws {
    let ciphertextOriginal = "U2FsdGVkX18/SWOonW/UfODCpIrRFuOUKITIvRob3iE="
    let key = "XxJNyUTlCFrrbTG"
  }

  func testKeyGen() async throws {
    let ciphertextOriginal = "U2FsdGVkX18/SWOonW/UfODCpIrRFuOUKITIvRob3iE="
    let key = "XxJNyUTlCFrrbTG"

    let (secret, iv, cipher) = AESCBCHelper.getAESParams(
      ciphertextCombined: ciphertextOriginal, passPhrase: key)

    let (expectedSecret, expectedIv, expectedCipher) = (
      Data(base64Encoded: "CRrEAHjh0EX3wCEm+suTFwGw27lQZ6o+AhqPNuX/BB8="),
      Data(base64Encoded: "ia5AvWFxxS0t/HK0NXiKgg=="),
      Data(base64Encoded: "4MKkitEW45QohMi9GhveIQ==")
    )

    XCTAssertEqual(secret, expectedSecret)
    XCTAssertEqual(iv, expectedIv)
    XCTAssertEqual(cipher, expectedCipher)

  }

}
