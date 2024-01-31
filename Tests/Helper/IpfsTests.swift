import Push
import XCTest

class IpfsTests: XCTestCase {

  func testGetCID() async throws {
    let cid = "v2:8884b4e8df8e6ea8985bac41f4cd87407c02a2ac1d411033bd0586a252b6c536"
    let message = try await Push.getCID(env: ENV.DEV, cid: cid)

    print("got the message: \(message)")

    // XCTAssertNotNil(message.fromCAIP10, "from CAIP10 should not be nil")
    // XCTAssertNotNil(message.toCAIP10, "to CAIP10 should not be nil")
    // XCTAssertNotNil(message.messageType, "messageType should not be nil")
    // XCTAssertNotNil(message.messageContent, "messageContent should not be nil")

    // XCTAssertEqual(message.fromCAIP10, message.fromDID, "from CAIP10 should be equal to from DID")
    // XCTAssertEqual(message.toCAIP10, message.toDID, "to CAIP10 should be equal to to DID")
    // XCTAssert(message.encType == "pgp", "encType should be pgp")

    // XCTAssertTrue(
    //   message.signature.hasPrefix("-----BEGIN PGP SIGNATURE-----"),
    //   "signature should begin with appropriate prefix")
    // XCTAssertTrue(
    //   message.signature.hasSuffix("-----END PGP SIGNATURE-----\n"),
    //   "signature should end with appropriate suffix")
    // XCTAssertTrue(
    //   message.encryptedSecret!.hasPrefix("-----BEGIN PGP MESSAGE-----"),
    //   "encryptedSecret should begin with appropriate prefix")
    // XCTAssertTrue(
    //   message.encryptedSecret!.hasSuffix("-----END PGP MESSAGE-----\n"),
    //   "encryptedSecret should end with appropriate suffix")

    // https://backend-dev.epns.io/apis/v1/ipfs/v2:8884b4e8df8e6ea8985bac41f4cd87407c02a2ac1d411033bd0586a252b6c536?
    // https://backend-dev.epns.io/apis/v1/ipfs/v2:8884b4e8df8e6ea8985bac41f4cd87407c02a2ac1d411033bd0586a252b6c536%3F?
    // https://backend-dev.epns.io/apis/v1/ipfs/v2:8884b4e8df8e6ea8985bac41f4cd87407c02a2ac1d411033bd0586a252b6c536?
  }

  func testGetInvalidCID() async throws {
    let invalidCid = "bafyreiauddxpzcgcwphwhsvldctuka6tvtwsfbga6v57p4gno2zpo3vmtm123"
    do {
      let _ = try await Push.getCID(env: ENV.STAGING, cid: invalidCid)
      XCTFail("Should throw error")
    } catch {
      XCTAssertTrue(
        error.localizedDescription.contains("The operation couldn’t be completed."),
        "Error should be NSURLErrorDomain error since the CID is invalid."
      )
    }
  }
}
