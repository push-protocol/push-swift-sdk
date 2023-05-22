import CryptoKit

public func generateSHA256Hash(msg: String) -> String {
  let data = msg.data(using: .utf8)!
  let hash = SHA256.hash(data: data)
  let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()
  return hashString
}
