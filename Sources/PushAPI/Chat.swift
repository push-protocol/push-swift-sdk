public struct Chat {
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

    public func list(type: ChatListType, page: Int = 1, limit: Int = 10, overrideAccount: String? = nil) async throws -> [PushChat.Feeds] {
        if type == .CHAT {
            let options = PushChat.GetChatsOptions(
                account: account,
                pgpPrivateKey: decryptedPgpPvtKey,
                page: page, limit: limit, env: env)

            return try await PushChat.getChats(
                options: options
            )

        } else {
            let options = PushChat.RequestOptionsType(
                account: account,
                pgpPrivateKey: decryptedPgpPvtKey,
                page: page, limit: limit, env: env)
            return try await PushChat.requests(options: options)
        }
    }
}

public enum ChatListType {
    case CHAT
    case REQUESTS
}
