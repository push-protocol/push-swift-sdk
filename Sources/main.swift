import Foundation

let signer = Signer(privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
let userAddress = "eip155:0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"

let user = try await User.get(account: userAddress, env: .STAGING)!

let encPK = user.encryptedPrivateKey

struct EncryptedPrivateKey: Codable {
  var ciphertext: String
  var version: String
  var salt: String
  var nonce: String
  var preKey: String
}

let jsonData = encPK.data(using: .utf8)!
let decoder = JSONDecoder()
let pp = try decoder.decode(EncryptedPrivateKey.self, from: jsonData)

let secret = try signer.getEip191Signature(message: "Enable Push Profile \n\(pp.preKey)")
let pgpPrivateKey = try AESGCMHelper.decrypt(
  chiperHex: pp.ciphertext, secret: secret, nonceHex: pp.nonce, saltHex: pp.salt)

let chats = try await Chats.getChats(
  options: GetChatsOptions(account: userAddress, pgpPrivateKey: pgpPrivateKey, toDecrypt: true))

for chat in chats {
  print("Message:",chat.msg!.messageContent, "Time Stamp:", chat.msg!.timestamp!)
}
