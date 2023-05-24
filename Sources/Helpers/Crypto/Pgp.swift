import ObjectivePGP

public struct Pgp {
  public let publicKey: Data
  let secretKey: Data

  public init(publicKey: Data, secretKey: Data) throws {

    self.publicKey = publicKey
    self.secretKey = secretKey
  }

  public func preparePGPPublicKey(signer: Push.Singer) throws -> String {
    let createProfileMessage =
      "Create Push Profile \n" + generateSHA256Hash(msg: self.getPublicKey())
    let verificationProof = try signer.getEip191Signature(message: createProfileMessage)

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

  func useEmptyPassPhrase(key: Key?) -> String? {
    return ""
  }

}
