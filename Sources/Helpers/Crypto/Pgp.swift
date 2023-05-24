import ObjectivePGP

public struct Pgp {
  let publicKey: Data
  let secretKey: Data

  public init() throws {
    let key = KeyGenerator().generate(for: "", passphrase: "")

    let publicKey = try key.export(keyType: .public)
    let secretKey = try key.export(keyType: .secret)

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

  public func encryptWithPGPKey(message: Data, anotherUserPublicKey: Data) throws -> Data {
    let myKey = try ObjectivePGP.readKeys(from: self.publicKey).first!
    let anotherUserKey = try ObjectivePGP.readKeys(from: anotherUserPublicKey).first!
    let encrypted = try ObjectivePGP.encrypt(
      message, addSignature: false, using: [anotherUserKey, myKey])
    return encrypted
  }

  public func decryptWithPGPKey(message: Data) throws -> Data {
    let myKey = try ObjectivePGP.readKeys(from: self.publicKey).first!
    let decrypted = try ObjectivePGP.decrypt(
      message, andVerifySignature: false, using: [myKey])

    return decrypted
  }

  public func verify(encryptedBin: Data, signature: Data) throws -> Bool {
    let myKey = try ObjectivePGP.readKeys(from: self.publicKey).first!
    try ObjectivePGP.verify(encryptedBin, withSignature: signature, using: [myKey])
    return true
  }

  public func sign(encryptedBin: Data) throws -> Data {
    let myKey = try ObjectivePGP.readKeys(from: self.publicKey).first!
    let signature = try ObjectivePGP.sign(encryptedBin, detached: true, using: [myKey])
    return signature
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
    return try Pgp()
  }

}
