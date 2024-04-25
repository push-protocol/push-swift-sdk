import Foundation

public struct Profile {
    private var account: String
    private var decryptedPgpPvtKey: String
    private var env: ENV

    init(
        account: String,
        decryptedPgpPvtKey: String,
        env: ENV
    ) {
        self.account = account
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.env = env
    }

    public func info(overrideAccount: String? = nil) async throws -> PushUser? {
        return try? await PushUser.get(account: overrideAccount ?? account, env: env)
    }

    public func update(name: String? = nil, desc: String? = nil, picture: String? = nil) async throws {
        let info = try? await info()
        var profile = info!.profile
        profile.name = name ?? profile.name
        profile.desc = desc ?? profile.desc
        profile.picture = picture ?? profile.picture

      try await  PushUser.updateUserProfile(account: account, pgpPrivateKey: decryptedPgpPvtKey, newProfile: profile, env: env)
    }
}
