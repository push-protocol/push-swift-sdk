import Foundation

public struct PushAPI {
    private var env: ENV
    public var account: String
    private var readMode: Bool
    private var decryptedPgpPvtKey: String
    private var pgpPublicKey: String?
    private var signer: Signer

    public var chat: Chat
    public var profile: Profile

    init(env: ENV,
         account: String,
         readMode: Bool,
         decryptedPgpPvtKey: String,
         pgpPublicKey: String?,
         signer: Signer) {
        self.env = env
        self.account = account
        self.readMode = readMode
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.pgpPublicKey = pgpPublicKey
        self.signer = signer

        chat = Chat(account: account, decryptedPgpPvtKey: decryptedPgpPvtKey, env: env)
        profile = Profile(account: account, decryptedPgpPvtKey: decryptedPgpPvtKey, env: env)
    }

    public static func initializePush(signer: Signer, options: PushAPIInitializeOptions) async throws -> PushAPI {
        // Get account
        // Derives account from signer if not provided
        let derivedAccount = try await signer.getAddress()

        var decryptedPGPPrivateKey: String?
        var pgpPublicKey: String?

        /**
         * Decrypt PGP private key
         * If user exists, decrypts the PGP private key
         * If user does not exist, creates a new user and returns the decrypted PGP private key
         */
        if let user = try await PushUser.get(account: derivedAccount, env: options.env) {
            decryptedPGPPrivateKey = try await PushUser.DecryptPGPKey(encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)
            pgpPublicKey = user.publicKey
        } else {
            let newUser = try await PushUser.create(
                options: PushUser.CreateUserOptions(
                    env: options.env,
                    signer: signer,
                    progressHook: nil
                ))

            decryptedPGPPrivateKey = try await PushUser.DecryptPGPKey(encryptedPrivateKey: newUser.encryptedPrivateKey, signer: signer)
            pgpPublicKey = newUser.publicKey
        }

        return PushAPI(env: options.env,
                       account: derivedAccount,
                       readMode: true,
                       decryptedPgpPvtKey: decryptedPGPPrivateKey!,
                       pgpPublicKey: pgpPublicKey,
                       signer: signer)
    }
}

extension PushAPI {
    public struct PushAPIInitializeOptions {
        var env: ENV
        var version: ENCRYPTION_TYPE
        var versionMeta: [String: [String: String]]?
        var autoUpgrade: Bool
        var origin: String?

        public init(
            env: ENV = .PROD,
            version: ENCRYPTION_TYPE = .PGP_V3,
            versionMeta: [String: [String: String]]? = nil,
            autoUpgrade: Bool = true,
            origin: String? = nil) {
            self.env = env
            self.version = version
            self.versionMeta = versionMeta
            self.autoUpgrade = autoUpgrade
            self.origin = origin
        }
    }
}
