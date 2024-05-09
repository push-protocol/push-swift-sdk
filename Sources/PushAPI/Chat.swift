public struct Chat {
    private var account: String
    private var decryptedPgpPvtKey: String
    private var env: ENV

    public var group: Group

    init(
        account: String,
        decryptedPgpPvtKey: String,
        env: ENV
    ) {
        self.account = account
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.env = env

        group = Group(account: account, decryptedPgpPvtKey: decryptedPgpPvtKey, env: env)
    }

    public enum ChatListType {
        case CHAT
        case REQUESTS
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

    public func latest(target: String) async throws -> Message? {
        let threadHash = try await PushChat.ConversationHash(conversationId: target, account: account, env: env)

        if threadHash == nil {
            return nil
        }

        let latestMessage = try await PushChat.History(
            threadHash: threadHash!, limit: 1, pgpPrivateKey: decryptedPgpPvtKey, toDecrypt: true, env: env
        ).first

        return latestMessage
    }

    public func history(
        target: String, reference: String? = nil, limit: Int = 10
    ) async throws -> [Message] {
        var ref = reference
        if ref == nil {
            let threadHash = try await PushChat.ConversationHash(conversationId: target, account: account, env: env)!
            ref = threadHash
        }

        if ref == nil {
            return []
        }

        return try await PushChat.History(
            threadHash: ref!, limit: limit,
            pgpPrivateKey: decryptedPgpPvtKey,
            toDecrypt: true, env: env)
    }

    public func accept(target: String) async throws -> String? {
        let options = PushChat.ApproveOptions(requesterAddress: target, approverAddress: account, privateKey: decryptedPgpPvtKey, env: env)

        return try await PushChat.approve(options)
    }


    public func block(users: [String]) async throws {
        let user = try await PushUser.get(account: account, env: env)
        var profile = user?.profile

        for address in users {
            if !isValidETHAddress(address: address) {
                fatalError("Invalid member address!")
            }
        }

        var updatedBlockedUsersList = profile?.blockedUsersList ?? []
        updatedBlockedUsersList.append(contentsOf: users)
        profile!.blockedUsersList = Array(Set(updatedBlockedUsersList))

        try await PushUser.updateUserProfile(account: account, pgpPrivateKey: decryptedPgpPvtKey, newProfile: profile!, env: env)
    }

    public func unblock(users: [String]) async throws {
        let user = try await PushUser.get(account: account, env: env)
        var profile = user?.profile

        for address in users {
            if !isValidETHAddress(address: address) {
                fatalError("Invalid member address!")
            }
        }

        var updatedBlockedUsersList = profile?.blockedUsersList ?? []
        updatedBlockedUsersList.append(contentsOf: users)
        profile!.blockedUsersList = profile?.blockedUsersList?.filter { blockedUser in
            !users.contains(blockedUser.lowercased())
        }

        try await PushUser.updateUserProfile(account: account, pgpPrivateKey: decryptedPgpPvtKey, newProfile: profile!, env: env)
    }

    public func info(chatId: String) async throws -> PushChat
        .PushGroupInfoDTO {
        return try await PushChat.getGroupInfoDTO(chatId: chatId, env: env)
    }
}

public struct Group {
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

    func leave(target: String) async throws -> PushChat.PushGroupInfoDTO? {
        let options = PushChat.UpdateGroupMemberOptions(account: account, chatId: target,remove:  [account], pgpPrivateKey: decryptedPgpPvtKey)
        
        return try await PushChat.updateGroupMember(options: options, env: env)
    }

    func join(target: String) async throws -> PushChat.PushGroupInfoDTO? {
        let status = try await PushChat.getGroupMemberStatus(chatId: target, did: account, env: env)

        if status!.isPending {
            let approved = try await PushChat.approve(PushChat.ApproveOptions(requesterAddress: target, approverAddress: account, privateKey: decryptedPgpPvtKey, env: env))

            return try await info(chatId: target)

        } else {
            let options = PushChat.UpdateGroupMemberOptions(account: account, chatId: target, upsert: PushChat.UpsertData(members: [account]), pgpPrivateKey: decryptedPgpPvtKey)
            return try await PushChat.updateGroupMember(options: options, env: env)
        }
    }
    
//    func reject(target: String) async throws -> PushChat.PushGroupInfoDTO? {
//        
//    }
//    
    

    public func info(chatId: String) async throws -> PushChat
        .PushGroupInfoDTO {
        return try await PushChat.getGroupInfoDTO(chatId: chatId, env: env)
    }
}
