import Push
import XCTest

class PgpTests: XCTestCase {

  func testPgpPairGenration() async throws {
    let pair = try Push.Pgp.GenerateNewPgpPair()

    XCTAssert(pair.getPublicKey().count > 0, "Public key is empty")
    XCTAssert(pair.getSecretKey().count > 0, "Secret key is empty")
  }

  func testPgpSenderAndReceiverCanDecrypt() async throws {
    let pair1 = try Pgp.GenerateNewPgpPair()
    let pair2 = try Pgp.GenerateNewPgpPair()

    let originalMessage = "This is a good place to find a city"
    let message = originalMessage.data(using: .utf8)!

    let encMsg = try pair1.encryptWithPGPKey(
      message: message, anotherUserPublicKey: pair2.publicKey)

    XCTAssertTrue(
      encMsg.hasPrefix("-----BEGIN PGP MESSAGE-----"),
      "encryptedSecret should begin with appropriate prefix")
    XCTAssertTrue(
      encMsg.hasSuffix("-----END PGP MESSAGE-----\n"),
      "encryptedSecret should end with appropriate suffix")

    let decMsg1 = try pair1.decryptWithPGPKey(message: encMsg)
    let decMsg2 = try pair2.decryptWithPGPKey(message: encMsg)

    XCTAssertEqual(originalMessage, decMsg1)
    XCTAssertEqual(originalMessage, decMsg2)
  }

  func testPgpSignatureVerification() async throws {

    let pair1 = try Pgp.fromArmor(publicKey: pubKey, secretKey: secKey)
    let pair2 = try Pgp.GenerateNewPgpPair()

    let originalMessage = "This is a good place to find a city"
    let message = originalMessage.data(using: .utf8)!

    let encMsg = try pair1.encryptWithPGPKey(
      message: message, anotherUserPublicKey: pair2.publicKey)

    let sig = try pair1.sign(encryptedData: encMsg)

    XCTAssertTrue(
      sig.hasPrefix("-----BEGIN PGP SIGNATURE-----"),
      "signature should begin with appropriate prefix")
    XCTAssertTrue(
      sig.hasSuffix("-----END PGP SIGNATURE-----\n"),
      "signature should end with appropriate suffix")

    let isSigVerified = try pair1.verify(encryptedData: encMsg, signature: sig)
    XCTAssert(isSigVerified)

  }

  struct AcceptHashData: Encodable {
    var fromDID: String
    var toDID: String
    var status: String
  }

  func testPgpSig() async throws {
    let message = "af0e555cc21ad40b2eec3b8453e4f206a43483be95accfe320e657941d63c77a"

    let fromDID = walletToPCAIP10(account: "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c")
    let toDID = walletToPCAIP10(account: "0xA7226C6227A2afe0556020Eb02F1524e41fc4F9c")

    let apiData = AcceptHashData(
      fromDID: fromDID,
      toDID: toDID, status: "Approved")

    let hash = generateSHA256Hash(
      msg:
        String(data: try JSONEncoder().encode(apiData), encoding: .utf8)!
    )

    let signature = try Pgp.sign(message: hash, privateKey: secKey)

    XCTAssertEqual(message, hash)

    print(signature)

  }
}

let pubKey = """
  -----BEGIN PGP PUBLIC KEY BLOCK-----

  xsBNBGRuQYsBCACtJDoFFbAcrTJFemnwx5TwdSWPar/oioJQ7z4MQGg7EDmT
  K4wlG3hS1jhvZA0xXUQmClNHhFXAWDtx2LjU1tb5wmf4qXj1jEaVCLltJUOl
  2lyvNYLCT8lS0vNrX+5KS118HHI6idqFGqUyo5f2pkDOd0QC1MvDkXnnwCm6
  elzsZaDhcPN0p2c80ivADjqrL1AhPHebRDv6Lc717npxhABZ5/WWDdDe30D/
  CV9wcEcNBaUKGgzGNiLB+RshASrQSnaKJLW2SpgbLZViwoDuY/h+CQZRtTxf
  +trfGBvuoPToNv6evyz1sBV7hlvCYIX+BfmjHUUC3FRP/04uYWmsG8U/ABEB
  AAHNAMLAigQQAQgAPgWCZG5BiwQLCQcICZCVj87xVbw6MwMVCAoEFgACAQIZ
  AQKbAwIeARYhBHYRAHPmCag6IUt/45WPzvFVvDozAAAtrAf+MysM5A96jHud
  1PLw9LRFa9JLJ/YSPQM7+9vtIQLMBVdhHWwY0GqGGOPkKSQhivhj76LJTjuL
  1qmY7J225XKIflHKoo6KCYOZZ6UqQY2n1GVLF7JHBxoiocNS9bwOAAksKTjj
  D/hPp427GAgMAcBF4zkpGR3uiPwB2WisZvn19HbxKIW9OtQHipQXKugiSQJT
  EFNxmshknZnU+AANz/jszMTHYlXtKL9R30z+J5Sov9Dadu/KmWmtymed4RJE
  V8L/FcpQZ79bP0fMRAhf5SVLIv/RB7FpKDaf8NA2VYI8/yDBLjUhwWKBmpnB
  QuOffHY2DR4vDruKedZj7ehTk1cffc7ATQRkbkGLAQgA2C3NDcDM9lEZMzDK
  8bO978FuePYYh8IHGEERXY5KGvGpE/YGLTLTuNpcOBl8lIKanAp3j1uPJwc1
  I4eYKzeZxWAX8OTHD4go7Zy9XOn2GoHDZsc4iW1cLFnmxKHq4lKOp6BpJ8q3
  DBwqEKPKySuBold1zr4xhV50zc6I+P4664LHFOBkjfPkTXBMHfeczzKizPRI
  85mvxYk8OkFBtUlzzDBkUZJc4vreiXAb0OIHz+kusxlXFTZmsjA92lW8j9UQ
  lqh8NU5vu3UAH3R+nVPlVWK3E7DK5j4Tp6zts2R/zoD0NbqPUoYl7YE6U6To
  5TrtrtvJJ0k6o+nkfd5N+rcPMwARAQABwsB2BBgBCAAqBYJkbkGLCZCVj87x
  Vbw6MwKbDBYhBHYRAHPmCag6IUt/45WPzvFVvDozAAC7ywf/Zhe+Qhk2YAhR
  BGWcs6iEFIDuIKF9Jw45DUhypgtwSWWZih9rESY6PI3u6RxA5th8rnbIRUrP
  OXM+uJIl10cW7WOVW0FqCPCPpJWyJYwP45cQXz7zmluxZUxl0Lq9gb5bRjsZ
  KVDDufwhKz9oTYf/n5rqX8BxpppTsVkHTdi2pVtpu38qxGsRAjDTn3XxFyXR
  TLBxZ8qVJSjOxHl7LkQqu5dxsASYJlZJTV02LmYO7q/mwzKvC/XCLog8Xvx5
  cTOfSrR4b+56AzONLoOsExTsYulwThDx72JE1HrQul3W1wT31c5QKb/mpKks
  S1a0WgBe6MldzvXRTsq39bHNbh7bzQ==
  =7SWu
  -----END PGP PUBLIC KEY BLOCK-----
  """

let secKey = """
  -----BEGIN PGP PRIVATE KEY BLOCK-----

  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
  WgBe6MldzvXRTsq39bHNbh7bzQ==
  =7og+
  -----END PGP PRIVATE KEY BLOCK-----
  """
