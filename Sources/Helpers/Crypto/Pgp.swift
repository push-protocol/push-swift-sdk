import CryptoKit
import ObjectivePGP
import web3

let KDFSaltSize = 32  // bytes
let AESGCMNonceSize = 12  // property iv

func getRandomValues(array: inout [UInt8]) {
  _ = SecRandomCopyBytes(kSecRandomDefault, array.count, &array)
}

func bytesToHex(bytes: [UInt8]) -> String {
  return bytes.map { String(format: "%02hhx", $0) }.joined()
}

func recoverAddressFromSignature(signature: String, signedData: String) throws -> String {
  // TODO: Implement
  return ""
}

func verifyProfileSignature(verificationProof: String, signedData: String, wallet: String) throws
  -> Bool
{
  let length = verificationProof.split(separator: ":").count
  let signature = verificationProof.split(separator: ":")[length - 1]
  let _ = try recoverAddressFromSignature(
    signature: String(signature), signedData: signedData)
  // TODO: return recoveredAddress.lowercased() == wallet.lowercased();
  return true
}

enum PgpError: Error {
  case INVALID_PUBLIC_KEY
  case INVALID_PRIVATE_KEY
  case INVALID_SIGNATURE
  case INVALID_ENCRYPTED_MESSAGE
  case INVALID_DECRYPTED_MESSAGE
}

public struct EncryptedPrivateKeyV2: Encodable {
  var ciphertext: String
  var salt: String?
  var nonce: String
  var version: ENCRYPTION_TYPE?
  var preKey: String?
}

public struct Pgp {
  public let publicKey: Data
  let secretKey: Data

  public init(publicKey: Data, secretKey: Data) throws {

    self.publicKey = publicKey
    self.secretKey = secretKey
  }

  public func preparePGPPublicKey(signer: Push.Signer) async throws -> String {
    let createProfileMessage =
      "Create Push Profile \n" + generateSHA256Hash(msg: self.getPublicKey())
    let verificationProof = try await signer.getEip191Signature(message: createProfileMessage)

    let chatPublicKey = [
      "key": self.getPublicKey(),
      "signature": verificationProof,
    ]

    let chatPKJsonData = try JSONSerialization.data(withJSONObject: chatPublicKey, options: [])
    let chatPKeyJsonString = String(data: chatPKJsonData, encoding: .utf8)!

    return chatPKeyJsonString

  }

  public func encryptWithPGPKey(message: Data, anotherUserPublicKey: Data) throws -> String {
    let myKey = try ObjectivePGP.readKeys(from: self.publicKey).first!
    let anotherUserKey = try ObjectivePGP.readKeys(from: anotherUserPublicKey).first!
    let encrypted = try ObjectivePGP.encrypt(
      message, addSignature: false, using: [anotherUserKey, myKey])
    return Armor.armored(encrypted, as: .message)
  }

  public func decryptWithPGPKey(message: String) throws -> String {
    let messageData = try Armor.readArmored(message)
    let myKey = try ObjectivePGP.readKeys(from: self.secretKey).first!
    let decrypted = try ObjectivePGP.decrypt(
      messageData, andVerifySignature: false, using: [myKey], passphraseForKey: useEmptyPassPhrase)

    return String(data: decrypted, encoding: .utf8)!
  }

  public func verify(encryptedData: String, signature: String) throws -> Bool {
    let encryptedBin = try Armor.readArmored(encryptedData)
    let signatureBin = try Armor.readArmored(signature)
    let myKey = try ObjectivePGP.readKeys(from: self.publicKey).first!
    try ObjectivePGP.verify(encryptedBin, withSignature: signatureBin, using: [myKey])
    return true
  }

  public func sign(encryptedData: String) throws -> String {
    let encryptedBin = try Armor.readArmored(encryptedData)
    let mySk = try ObjectivePGP.readKeys(from: self.secretKey).first!
    // let myPk = try ObjectivePGP.readKeys(from: self.secretKey).first!
    let signature = try ObjectivePGP.sign(
      encryptedBin, detached: true, using: [mySk], passphraseForKey: useEmptyPassPhrase)
    return Armor.armored(signature, as: .signature)
  }

  public func getPublicKey() -> String {
    return
      Armor.armored(self.publicKey, as: .publicKey)
  }

  public func getSecretKey() -> String {
    return
      Armor.armored(self.secretKey, as: .secretKey)
  }

  public static func GenerateNewPgpPair() throws -> Self {
    let key = KeyGenerator(
      algorithm: .RSA, keyBitsLength: 2048, cipherAlgorithm: .AES256, hashAlgorithm: .SHA256
    ).generate(for: "", passphrase: "")

    let publicKey = try key.export(keyType: .public)
    let secretKey = try key.export(keyType: .secret)
    return try Pgp(publicKey: publicKey, secretKey: secretKey)
  }

  public static func fromArmor(publicKey: String, secretKey: String) throws -> Self {
    let pk = try Armor.readArmored(publicKey)
    let sk = try Armor.readArmored(secretKey)

    return try Pgp(publicKey: pk, secretKey: sk)
  }

  public static func verifyPGPPublicKey(encryptionType: String, publicKey: String, did: String)
    throws -> String
  {
    guard
      let parsedPublicKey = try? JSONSerialization.jsonObject(with: publicKey.data(using: .utf8)!)
        as? [String: String],
      let key = parsedPublicKey["key"],
      let verificationProof = parsedPublicKey["signature"]
    else {
      throw PgpError.INVALID_PUBLIC_KEY
    }

    let pCAIP10Wallet = pCAIP10ToWallet(address: did)
    let signedData = "Create Push Profile \n" + generateSHA256Hash(msg: key)

    if try verifyProfileSignature(
      verificationProof: verificationProof, signedData: signedData, wallet: pCAIP10Wallet)
    {
      return key
    } else {
      throw PgpError.INVALID_SIGNATURE
    }
  }

  func useEmptyPassPhrase(key: Key?) -> String? {
    return ""
  }

  public func encryptPGPKey(wallet: Push.Wallet) async throws -> EncryptedPrivateKeyV2 {
    var array = [UInt8](repeating: 0, count: 32)
    getRandomValues(array: &array)
    let input = bytesToHex(bytes: array)
    let enableProfileMessage = "Enable Push Profile \n" + input
    let verificationProof = try await wallet.getEip191Signature(message: enableProfileMessage)
    // let encodedPrivateKey = Array(getSecretKey().utf8);
    let encodedPrivateKeyString = getSecretKey()

    var salt = [UInt8](repeating: 0, count: KDFSaltSize)
    var nonce = [UInt8](repeating: 0, count: AESGCMNonceSize)
    getRandomValues(array: &salt)
    getRandomValues(array: &nonce)
    let encrypted = try AESGCMHelper.encrypt(
      message: encodedPrivateKeyString,
      secret: verificationProof,
      nonceHex: bytesToHex(bytes: nonce),
      saltHex: bytesToHex(bytes: salt)
    )
    return EncryptedPrivateKeyV2(
      ciphertext: encrypted,
      salt: bytesToHex(bytes: salt),
      nonce: bytesToHex(bytes: nonce),
      version: ENCRYPTION_TYPE.PGP_V3,
      preKey: input
    )
  }

  static func filterMobilePgpInfo(_ inputString: String) -> String {
    var lines: [String] = inputString.components(separatedBy: .newlines)
    if lines.count >= 2 && lines[1].contains("Version: openpgp-mobile") {
      lines.remove(at: 1)
      return lines.joined(separator: "\n")
    } else {
      return inputString
    }
  }

  public static func pgpDecrypt(cipherText: String, toPrivateKeyArmored: String) throws -> String {

    let pkData = try Armor.readArmored(toPrivateKeyArmored)
    let privateKey = try ObjectivePGP.readKeys(from: pkData).first!

    let decryptData = try Armor.readArmored(cipherText)
    let decryptedData = try ObjectivePGP.decrypt(
      decryptData, andVerifySignature: false, using: [privateKey])

    guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
      throw PgpError.INVALID_DECRYPTED_MESSAGE
    }
    return decryptedString
  }
}
