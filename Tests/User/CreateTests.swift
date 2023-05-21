import Push
import Web3
import XCTest

class CreateUserTests: XCTestCase {

  func testUserGetReturnsNilWhenUserDoesNotExist() async throws {
    let userAccount = try! EthereumPrivateKey(
      hexPrivateKey: "0xa26da69ed1df3ba4bb2a231d506b711eace012f1bd2571dfbfff9650b03375af")

    let userAddres = userAccount.address.hex(eip55: true)

    // let op = CreateUserProps(account: "exampleAccount", signer: "exampleSigner", version: Push.ENCRYPTION_TYPE.PGP_V3, additionalMeta: "exampleMeta");
    await Push.User.create(
      env: Push.ENV.STAGING, account: userAddres, signer: userAddres,
      version: Push.ENCRYPTION_TYPE.PGP_V3, additionalMeta: "")

  }

}
