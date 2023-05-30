import CommonCrypto
import CryptoKit
import Foundation

public struct AESCBCHelper {
  public static func decrypt(cipherText: String, secretKey: String) -> Data? {
    let (secret, iv, chiper) = AESCBCHelper.getAESParams(
      ciphertextCombined: cipherText, passPhrase: secretKey)

    let dec = AESCBCHelper._decrypt(data: chiper, key: secret, iv: iv)
    return dec
  }

  static func _encrypt(data: Data, key: Data, iv: Data) -> Data? {
    // Output buffer (with padding)
    let outputLength = data.count + kCCBlockSizeAES128
    var outputBuffer = [UInt8](
      repeating: 0,
      count: outputLength)
    var numBytesEncrypted = 0
    let status = CCCrypt(
      CCOperation(kCCEncrypt),
      CCAlgorithm(kCCAlgorithmAES),
      CCOptions(kCCOptionPKCS7Padding),
      Array(key),
      kCCKeySizeAES256,
      Array(iv),
      Array(data),
      data.count,
      &outputBuffer,
      outputLength,
      &numBytesEncrypted)
    guard status == kCCSuccess else {
      return nil
    }
    let outputBytes = outputBuffer.prefix(numBytesEncrypted)
    return Data(outputBytes)
  }

  static func _decrypt(data cipherData: Data, key: Data, iv: Data) -> Data? {
    // Split IV and cipher text
    let cipherTextLength = cipherData.count
    // Output buffer
    var outputBuffer = [UInt8](
      repeating: 0,
      count: cipherTextLength)
    var numBytesDecrypted = 0
    let status = CCCrypt(
      CCOperation(kCCDecrypt),
      CCAlgorithm(kCCAlgorithmAES),
      CCOptions(kCCOptionPKCS7Padding),
      Array(key),
      kCCKeySizeAES256,
      Array(iv),
      Array(cipherData),
      cipherTextLength,
      &outputBuffer,
      cipherTextLength,
      &numBytesDecrypted)
    guard status == kCCSuccess else {
      return nil
    }
    // Read output discarding any padding
    let outputBytes = outputBuffer.prefix(numBytesDecrypted)
    return Data(outputBytes)
  }

  public static func getAESParams(ciphertextCombined: String, passPhrase: String) -> (
    Data, Data, Data
  ) {
    func genMd5(data: Data) -> Data {
      let computed = Insecure.MD5.hash(data: data)
      return Data(computed.bytes)
    }

    let cipherDataAll = Data(base64Encoded: ciphertextCombined)!
    let passcode = passPhrase.data(using: .utf8)!

    let salt = cipherDataAll[8..<16]
    let ciphertext = cipherDataAll[16...]

    var derived = Data([])
    while derived.count < 48 {
      var toHash = Data([])
      if derived.count > 16 {
        toHash += derived[(derived.count - 16)...]
      } else {
        toHash += derived
      }

      toHash += passcode + salt

      let hash = genMd5(data: toHash)

      derived += hash
    }

    let originalkey = derived[0..<32]
    let iv = derived[32...]

    return (originalkey, iv, ciphertext)
  }

}
