import Push
import Web3Core
import XCTest
import web3swift

class CreateUserTests: XCTestCase {

  func testUserCreateFailsIfAlreadyExists() async throws {
    let expectation = XCTestExpectation(description: "Creates user successfully with account")
    do {
      let _ = try await PushUser.create(
        options: PushUser.CreateUserOptions(
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
    let userPk = getRandomAccount()
    let signer = try SignerPrivateKey(
      privateKey: userPk
    )
    let addrs = try await signer.getAddress()
    let userCAIPAddress = walletToPCAIP10(account: addrs)

    let user = try await PushUser.create(
      options: PushUser.CreateUserOptions(
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

  func testCreateUserEmpty() async throws {
    let userAddress = generateRandomEthereumAddress()
    let userCAIPAddress = walletToPCAIP10(account: userAddress)

    let user = try await PushUser.createUserEmpty(userAddress: userAddress, env: .STAGING)

    XCTAssertEqual(user.did, userCAIPAddress)
    XCTAssertEqual(user.wallets, userCAIPAddress)
    XCTAssertEqual(user.encryptedPrivateKey, "")
    XCTAssertEqual(user.getPGPPublickey(), "")

  }
}
