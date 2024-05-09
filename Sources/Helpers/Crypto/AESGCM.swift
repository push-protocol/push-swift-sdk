import CryptoKit
import Foundation

public struct AESGCMHelper {
    static func generateRandomSecret(length: Int) -> String {
        let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
        let charactersLength = characters.count
        var randomString = ""
        for _ in 0 ..< length {
            let randomIndex = Int.random(in: 0 ..< charactersLength)
            let character = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            randomString.append(character)
        }
        return randomString
    }

    static func hexToData(characters: String) -> Data {
        var data = Data(capacity: characters.count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: characters, options: [], range: NSMakeRange(0, characters.count)) {
            match, _, _ in
            let byteString = (characters as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }

        return data
    }

    static func hexToBytes(hex: String) -> [UInt8] {
        var bytes = [UInt8]()

        // TODO: this is a temp fix for this issue:  https://github.com/ethereum-push-notification-service/push-sdk/blob/e912f94fc72847[…]d303fd4e50e6bf001041/packages/restapi/src/lib/helpers/crypto.ts
        bytes.append(contentsOf: [14, 0, 145, 0, 0])

        for i in stride(from: 0, to: hex.count - 1, by: 2) {
            let start: String.Index = hex.index(hex.startIndex, offsetBy: i)
            let end = hex.index(hex.startIndex, offsetBy: i + 1)
            let sub = hex[start ... end]

            let pp = Int(sub, radix: 16)
            let num = (pp != nil ? pp : 0)!

            bytes.append(UInt8(num))
        }

        return bytes
    }

    static func getSigToBytes(sig: String) -> [UInt8] {
        let com = sig.components(separatedBy: ":")[1]
        let remaning = String(com.dropFirst(3))
        let res = hexToBytes(hex: remaning)
        return res
    }

    static func dataToHex(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
    }

    public static func decrypt(chiperHex: String, secret: String, nonceHex: String, saltHex: String)
        throws -> String {
        // Chat AES Info
        let chiper = hexToData(characters: chiperHex)
        let nonce = hexToData(characters: nonceHex)
        let salt = hexToData(characters: saltHex)

        let ciphertextBytes = chiper[0 ..< chiper.count - 16]
        let tag = chiper[chiper.count - 16 ..< chiper.count]

        let box = try AES.GCM.SealedBox(
            nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertextBytes, tag: tag)

        let sk = Data(
            getSigToBytes(sig: secret)
        )
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: sk),
            salt: salt,
            outputByteCount: 32
        )

        let res = try AES.GCM.open(box, using: derivedKey)
        return try res.toString()
    }

    public static func encrypt(message: String, secret: String, nonceHex: String, saltHex: String)
        throws -> String {
        // Chat AES Info
        let messageData = try message.toData()
        let nonce = hexToData(characters: nonceHex)
        let salt = hexToData(characters: saltHex)

        let sk = Data(
            getSigToBytes(sig: secret)
        )

        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: sk),
            salt: salt,
            outputByteCount: 32
        )

        let sealedBox = try AES.GCM.seal(
            messageData, using: derivedKey, nonce: AES.GCM.Nonce(data: nonce))
        let combinedEnc = sealedBox.ciphertext + sealedBox.tag
        let hexStr = dataToHex(combinedEnc)

        return hexStr
    }

    public static func decrypt(cipherText: String, secretKey: String) throws -> String {
        let cipherData = hexToData(characters: cipherText)
        let sk = Data(
            getSigToBytes(sig: secretKey)
        )
        let derivedKey = HKDF<SHA256>.deriveKey(
            inputKeyMaterial: SymmetricKey(data: sk),
            salt: Data(),
            outputByteCount: 32
        )
        let sealedBox = try AES.GCM.SealedBox(combined: cipherData)
        let decryptedData = try AES.GCM.open(sealedBox, using: derivedKey)
        return try decryptedData.toString()
    }

    func encryptAES(message: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(message, using: key)
        return sealedBox.combined!
    }

    func decryptAES(ciphertext: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: ciphertext)
        return try AES.GCM.open(sealedBox, using: key)
    }
}
