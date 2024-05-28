import CryptoSwift
import Foundation


import CommonCrypto

enum CryptoError: Error {
    case encryptionFailed
    case decryptionFailed
}

public func encryptionAESModeECB( data: Data, key: String) -> String? {
    guard let keyData = key.data(using: String.Encoding.utf8) else { return nil }
    guard let cryptData = NSMutableData(length: Int((data.count)) + kCCBlockSizeAES128) else { return nil }
    
    let keyLength               = size_t(kCCKeySizeAES128)
    let operation:  CCOperation = UInt32(kCCEncrypt)
    let algoritm:   CCAlgorithm = UInt32(kCCAlgorithmAES)
    let options:    CCOptions   = UInt32(kCCOptionECBMode + kCCOptionPKCS7Padding)
    let iv:         String      = ""
    
    var numBytesEncrypted: size_t = 0
    
    let cryptStatus = CCCrypt(operation,
                              algoritm,
                              options,
                              (keyData as NSData).bytes, keyLength,
                              iv,
                              (data as NSData).bytes, data.count,
                              cryptData.mutableBytes, cryptData.length,
                              &numBytesEncrypted)
    
    if UInt32(cryptStatus) == UInt32(kCCSuccess) {
        cryptData.length = Int(numBytesEncrypted)
        let encryptedString = cryptData.base64EncodedString(options: .lineLength64Characters)
        return encryptedString
//        return encryptedString.data(using: .utf8)
    } else {
        return nil
    }
}

public func aesEncrypt(plainText: String, secretKey: String) -> String? {
    guard let keyData = secretKey.data(using: .utf8),
          let encrypted = try? AES(key: keyData.bytes, blockMode: ECB()).encrypt(plainText.bytes) else {
        return nil
    }
    return encrypted.toBase64()
}


func aesDecrypt(cipherText: String, secretKey: String) throws -> String {
    guard let data = Data(base64Encoded: cipherText) else {
        fatalError("decryption failed")
    }
    guard let aes = try? AES(key: secretKey.bytes, blockMode: ECB(), padding: .pkcs7) else {
        fatalError("decryption failed")
    }
    let decryptedData = try aes.decrypt(data.bytes)
    guard let decryptedString = String(bytes: decryptedData, encoding: .utf8) else {
        fatalError("decryption failed")
    }
    return decryptedString
}

func generateRandomSecret(length: Int) -> String {
    let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    return String((0..<length).map { _ in characters.randomElement()! })
}
