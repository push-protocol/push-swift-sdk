import Foundation

enum PayloadHelper {
    public struct IEncryptedRequest {
        let message: String
        let encryptionType: String
        let aesEncryptedSecret: String
        let signature: String

        init(message: String, encryptionType: String, aesEncryptedSecret: String, signature: String) {
            self.message = message
            self.encryptionType = encryptionType
            self.aesEncryptedSecret = aesEncryptedSecret
            self.signature = signature
        }
    }

    public static func getEncryptedRequestCore(
        receiverAddress: String,
        senderAddress: String,
        senderPgpPrivateKey: String,
        message: String,
        isGroup: Bool,
        group: PushChat.PushGroupInfoDTO?,
        env: ENV,
        secretKey: String
    ) async throws -> IEncryptedRequest {
        let senderCreatedUser = try await PushUser.get(account: senderAddress, env: env)

        if !isGroup {
            if !isValidETHAddress(address: receiverAddress) {
                fatalError("Invalid receiver address!")
            }

            let receiverCreatedUser = try await PushUser.get(account: receiverAddress, env: env)
            if receiverCreatedUser?.publicKey == nil {
                let _ = try await PushUser.createUserEmpty(userAddress: receiverAddress, env: env)
                // If the user is being created here, that means that user don't have a PGP keys. So this intent will be in plaintext
                let signature = try await signMessageWithPGPCore(message: message, privateKeyArmored: senderPgpPrivateKey)

                return IEncryptedRequest(
                    message: message,
                    encryptionType: "PlainText",
                    aesEncryptedSecret: "",
                    signature: signature
                )
            } else {
                // It's possible for a user to be created but the PGP keys still not created
                if !receiverCreatedUser!.publicKey
                    .contains("-----BEGIN PGP PUBLIC KEY BLOCK-----")
                {
                    let signature = try await signMessageWithPGPCore(message: message, privateKeyArmored: senderPgpPrivateKey)

                    return IEncryptedRequest(
                        message: message,
                        encryptionType: "PlainText",
                        aesEncryptedSecret: "",
                        signature: signature
                    )

                } else {
                    let core = try await encryptAndSignCore(
                        plainText: message,
                        keys: [receiverCreatedUser!.getPGPPublickey(), senderCreatedUser!.getPGPPublickey()],
                        senderPgpPrivateKey: senderPgpPrivateKey,
                        secretKey: secretKey
                    )

                    return IEncryptedRequest(
                        message: core["cipherText"]!,
                        encryptionType: "pgp",
                        aesEncryptedSecret: core["encryptedSecret"]!,
                        signature: core["signature"]!
                    )
                }
            }
        } else if group != nil {
            if group!.isPublic {
                let signature = try await signMessageWithPGPCore(message: message, privateKeyArmored: senderPgpPrivateKey)

                return IEncryptedRequest(
                    message: message,
                    encryptionType: "PlainText",
                    aesEncryptedSecret: "",
                    signature: signature
                )
            } else {
                // Private Groups

                // 1. Private Groups with session keys
                if group?.sessionKey != nil && group?.encryptedSecret != nil {
                    let cipherText = try AESCBCHelper.encrypt(messageText: message, secretKey: secretKey)

                    let signature = try Pgp.sign(message: cipherText, privateKey: senderPgpPrivateKey)

                    return IEncryptedRequest(
                        message: message,
                        encryptionType: "pgpv1:group",
                        aesEncryptedSecret: "",
                        signature: signature
                    )
                } else {
                    let members = try await PushChat.getAllGroupMembersPublicKeysV2(chatId: group!.chatId, env: env)

                    let publicKeys = members!.map { $0.publicKey }

                    let core = try await encryptAndSignCore(
                        plainText: message,
                        keys: publicKeys,
                        senderPgpPrivateKey: senderPgpPrivateKey,
                        secretKey: secretKey
                    )

                    return IEncryptedRequest(
                        message: core["cipherText"]!,
                        encryptionType: "pgp",
                        aesEncryptedSecret: core["encryptedSecret"]!,
                        signature: core["signature"]!
                    )
                }
            }
        } else {
            fatalError("Unable to find Group Data")
        }
    }

    public static func signMessageWithPGPCore(message: String, privateKeyArmored: String) async throws -> String {
        return try Pgp.sign(message: message, privateKey: privateKeyArmored)
    }

    public static func encryptAndSignCore(
        plainText: String,
        keys: [String],
        senderPgpPrivateKey: String,
        secretKey: String
    ) async throws -> [String: String] {
        let cipherText = try AESCBCHelper.encrypt(messageText: plainText, secretKey: secretKey)

        let encryptedSecret = try Pgp.pgpEncryptV2(message: secretKey, pgpPublicKeys: keys)

        let signature = try Pgp.sign(message: cipherText, privateKey: senderPgpPrivateKey)

        let result = [
            "cipherText": cipherText,
            "encryptedSecret": encryptedSecret,
            "signature": signature,
            "sigType": "pgp",
            "encType": "pgp",
        ]
        return result
    }
}
