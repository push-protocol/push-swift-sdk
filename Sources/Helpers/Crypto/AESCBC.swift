import CommonCrypto
import CryptoKit
import Foundation

public struct AESCBCHelper {
  public static func decrypt(cipherText: String, secretKey: String) throws -> Data? {
    let (secret, iv, chiper) = try AESCBCHelper.getAESParams(
      ciphertextCombined: cipherText, passPhrase: secretKey)

    let dec = AESCBCHelper._decrypt(data: chiper, key: secret, iv: iv)
    return dec
  }

  public enum AES_CBC_ERROR: Error {
    case AES_CBC_DECRYPTION_FAILED
    case FAILED_TO_DECODE_AES_PARAMS
  }

  public static func encrypt(messageText: String, secretKey: String) throws -> String {
    let passcode = try secretKey.toData()

    let cipherTextPrefix = try "Salted__".toData()
    let salt = getRandomBytes(length: 8)

    let messageData = try messageText.toData()

    let (originalkey, iv) = deriveKeyAndIV(passcode: passcode, salt: salt)

    let originalCipher = try _encrypt(data: messageData, key: originalkey, iv: iv)
    let cipherPacked = cipherTextPrefix + salt + originalCipher
    let cipherBase64 = cipherPacked.base64EncodedString()

    return cipherBase64
  }

  static func _encrypt(data: Data, key: Data, iv: Data) throws -> Data {
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
      throw AESCBCHelper.AES_CBC_ERROR.AES_CBC_DECRYPTION_FAILED
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

  public static func getAESParams(ciphertextCombined: String, passPhrase: String) throws -> (
    Data, Data, Data
  ) {
    guard let cipherDataAll = Data(base64Encoded: ciphertextCombined) else {
      throw UtilsError.RUNTIME_ERROR("String")
    }

    guard let passcode = passPhrase.data(using: .utf8) else {
      throw UtilsError.RUNTIME_ERROR("String")
    }

    let salt = cipherDataAll[8..<16]
    let ciphertext = cipherDataAll[16...]

    let (originalkey, iv) = deriveKeyAndIV(passcode: passcode, salt: salt)
    return (originalkey, iv, ciphertext)
  }

}

func deriveKeyAndIV(passcode: Data, salt: Data) -> (Data, Data) {

  func genMd5(data: Data) -> Data {
    let computed = Insecure.MD5.hash(data: data)
    return Data(computed)
  }

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

  return (originalkey, iv)
}

func encodeToBase64(_ string: String) throws -> String {
  let data = try string.toData()
  return data.base64EncodedString()
}
