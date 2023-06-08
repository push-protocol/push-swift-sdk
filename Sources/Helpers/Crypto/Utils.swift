import CryptoKit
import Foundation

public func generateSHA256Hash(msg: String) -> String {
  let data = msg.data(using: .utf8)!
  let hash = SHA256.hash(data: data)
  let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
  return hashString
}

public func getRandomHexString(length: Int) -> String {
  var randomBytes = [UInt8](repeating: 0, count: length)
  _ = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
  let hexString = randomBytes.map { String(format: "%02hhx", $0) }.joined()
  return hexString
}

public func getRandomBytes(length: Int) -> Data {
  var randomBytes = [UInt8](repeating: 0, count: length)
  _ = SecRandomCopyBytes(kSecRandomDefault, length, &randomBytes)
  return Data(randomBytes)
}

public func getRandomString(withLength length: Int) -> String {
  let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  let randomString = String((0..<length).map { _ in letters.randomElement()! })
  return randomString
}
