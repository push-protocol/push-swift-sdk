import Push
import XCTest
import web3

class CreateUserTests: XCTestCase {
  func getRandomAccount() -> (String, String) {
    let length = 64
    let letters = "abcdef0123456789"
    let keyStorage = EthereumKeyLocalStorage()
    let privateKey = String((0..<length).map { _ in letters.randomElement()! })

    let account = try! EthereumAccount.importAccount(
      addingTo: keyStorage, privateKey: privateKey, keystorePassword: privateKey)

    let address = account.address.toChecksumAddress()
    return (address, privateKey)
  }

  func testThrowsErrorWhenBothSignerAndAccountAreNull() async throws {
    let expectation = XCTestExpectation(description: "Throws error")
    do {
      let _ = try await User.create(
        options: CreateUserOptions(
          env: ENV.STAGING,
          account: nil,
          signer: nil,
          version: ENCRYPTION_TYPE.PGP_V3,
          progressHook: nil
        ))
      XCTFail("Should have thrown error")
    } catch {
      expectation.fulfill()
    }
  }

  func testThrowsErrorWhenInvalidEthAddress() async throws {
    let expectation = XCTestExpectation(description: "Throws error")
    do {
      let _ = try await User.create(
        options: CreateUserOptions(
          env: ENV.STAGING,
          account: "eip155:0x3aae65DF8424b0B",
          signer: nil,
          version: ENCRYPTION_TYPE.PGP_V3,
          progressHook: nil
        ))
      XCTFail("Should have thrown error")
    } catch {
      expectation.fulfill()
    }
  }

  func testUserCreateFailsIfAlreadyExists() async throws {
    let expectation = XCTestExpectation(description: "Creates user successfully with account")
    do {
      let _ = try await User.create(
        options: CreateUserOptions(
          env: ENV.STAGING,
          account: "eip155:0x63FaC9201494f0bd17B9892B9fae4d52fe3BD377",
          signer: Signer(
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
        account: userAddress,
        signer: Signer(
          privateKey: userPk
        ),
        version: ENCRYPTION_TYPE.PGP_V3,
        progressHook: nil
      ))

    XCTAssertEqual(user.did, userCAIPAddress)
    XCTAssertEqual(user.wallets, userCAIPAddress)
    XCTAssert(user.encryptedPrivateKey.count > 0)
  }
}
