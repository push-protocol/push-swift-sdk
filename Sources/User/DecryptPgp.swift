import Foundation

extension PushUser {
  struct EncryptedPrivateKey: Codable {
    var ciphertext: String
    var version: String
    var salt: String
    var nonce: String
    var preKey: String
  }

  public static func DecryptPGPKey(encryptedPrivateKey: String, signer: Signer) async throws
    -> String
  {

    let wallet = try await Wallet(signer: signer)

    let jsonData = encryptedPrivateKey.data(using: .utf8)!
    let decoder = JSONDecoder()
    let pp = try decoder.decode(EncryptedPrivateKey.self, from: jsonData)

    let secret = try await wallet.getEip191Signature(message: "Enable Push Profile \n\(pp.preKey)")
    let pgpPrivateKey = try AESGCMHelper.decrypt(
      chiperHex: pp.ciphertext, secret: secret, nonceHex: pp.nonce, saltHex: pp.salt)

    return pgpPrivateKey
  }

}
