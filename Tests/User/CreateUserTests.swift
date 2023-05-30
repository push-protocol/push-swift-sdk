import Push
import XCTest
import Web3
class CreateUserTests: XCTestCase {
  func getRandomAccount() -> (String, String) {
    let length = 64
    let letters = "abcdef0123456789"
    let privateKey = String((0..<length).map { _ in letters.randomElement()! })

    let account = try! EthereumPrivateKey(hexPrivateKey: privateKey)

    let address = account.address.hex(eip55: true)
    return (address, privateKey)
  }

  func testUserCreateFailsIfAlreadyExists() async throws {
    let expectation = XCTestExpectation(description: "Creates user successfully with account")
    do {
      let _ = try await User.create(
        options: CreateUserOptions(
          env: ENV.STAGING,
          signer: SignerPrivateKey(
            privateKey: "8da4ef21b864d2cc526dbdb2a120bd2874c36c9d0a1fb7f8c63d7f7a8b41de8f"
          ),
          version: ENCRYPTION_TYPE.PGP_V3,
          progressHook: nil
        ))
      XCTFail("Should have thrown error, account already exists")
    } catch {
      expectation.fulfill()
    }
  }

  func testCreateNewUser() async throws {
    let (userAddress, userPk) = getRandomAccount()
    let userCAIPAddress = walletToPCAIP10(account: userAddress)

    let user = try await User.create(
      options: CreateUserOptions(
        env: ENV.STAGING,
        signer: SignerPrivateKey(
          privateKey: userPk
        ),
        progressHook: nil
      ))

    XCTAssertEqual(user.did, userCAIPAddress)
    XCTAssertEqual(user.wallets, userCAIPAddress)
    XCTAssert(user.encryptedPrivateKey.count > 0)
  }
}
