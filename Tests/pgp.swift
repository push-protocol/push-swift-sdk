import Push
import XCTest

class PPPTest: XCTestCase {

  func testWorks() async throws {
    let newUser = try Pgp.GenerateNewPgpPair()

    // let message = "This is a good place to find a city"
    print(newUser.getPublicKey())

    let sk = newUser.getSecretKey()
    print(sk)

    // let sig = try Pgp.sign(message: message, privateKey: sk)
    // print(sig)

  }
}
