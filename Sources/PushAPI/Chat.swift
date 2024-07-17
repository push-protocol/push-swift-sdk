import Foundation

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
    
    public func decrypt(messagePayloads:[Message] ) async throws-> [Message]{
        
        return messagePayloads;
    }

    public func list(type: ChatListType, page: Int = 1, limit: Int = 10, overrideAccount: String? = nil) async throws -> [PushChat.Feeds] {
        if type == .CHAT {
            let options = PushChat.GetChatsOptions(
                account: account,
                pgpPrivateKey: decryptedPgpPvtKey,
                toDecrypt: true,
                page: page,
                limit: limit,
                env: env)

            return try await PushChat.getChats(
                options: options
            )

        } else {
            let options = PushChat.RequestOptionsType(
                account: account,
                pgpPrivateKey: decryptedPgpPvtKey,
                page: page, 
                limit: limit,
                env: env)
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

    public func send(target: String, message: PushChat.SendMessage) async throws -> Message {
        let sendOption = PushChat.SendOptionsV2(
            to: target,
            message: message,
            account: account,
            pgpPrivateKey: decryptedPgpPvtKey,
            env: env
        )

        return try await Push.PushChat.sendV2(
            chatOptions: sendOption)
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

    public var participants: GroupParticipants

    public init(
        account: String,
        decryptedPgpPvtKey: String,
        env: ENV
    ) {
        self.account = account
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.env = env

        participants = GroupParticipants(env: env)
    }

    public func leave(target: String) async throws -> PushChat.PushGroupInfoDTO? {
        let options = PushChat.UpdateGroupMemberOptions(account: account, chatId: target, remove: [account], pgpPrivateKey: decryptedPgpPvtKey)

        return try await PushChat.updateGroupMember(options: options, env: env)
    }

    public func join(target: String) async throws -> PushChat.PushGroupInfoDTO? {
        let status = try? await PushChat.getGroupMemberStatus(chatId: target, did: account, env: env)
        print("Status: is null \(status == nil)")

        if status != nil && status?.isPending == true {
            let _ = try await PushChat.approve(PushChat.ApproveOptions(requesterAddress: target, approverAddress: account, privateKey: decryptedPgpPvtKey, env: env))

            return try await info(chatId: target)

        } else {
            let options = PushChat.UpdateGroupMemberOptions(
                account: account,
                chatId: target,
                upsert: PushChat.UpsertData(members: [account]),
                pgpPrivateKey: decryptedPgpPvtKey)
            return try await PushChat.updateGroupMember(options: options, env: env)
        }
    }

    public enum GroupRoles {
        case MEMBER
        case ADMIN
    }

    public func add(chatId: String, role: GroupRoles, accounts: [String]) async throws -> PushChat.PushGroupInfoDTO? {
        if accounts.isEmpty {
            fatalError("accounts array cannot be empty!")
        }

        for acc in accounts {
            if !isValidETHAddress(address: acc) {
                fatalError("Invalid account address: \(acc)")
            }
        }

        if role == .ADMIN {
            let options = PushChat.UpdateGroupMemberOptions(
                account: account,
                chatId: chatId,
                upsert: PushChat.UpsertData(admins: accounts),
                pgpPrivateKey: decryptedPgpPvtKey)
            return try await PushChat.updateGroupMember(options: options, env: env)
        } else {
            let options = PushChat.UpdateGroupMemberOptions(
                account: account,
                chatId: chatId,
                upsert: PushChat.UpsertData(members: accounts),
                pgpPrivateKey: decryptedPgpPvtKey)
            return try await PushChat.updateGroupMember(options: options, env: env)
        }
    }

    public func remove(chatId: String, role: GroupRoles, accounts: [String]) async throws -> PushChat.PushGroupInfoDTO? {
        if accounts.isEmpty {
            fatalError("accounts array cannot be empty!")
        }

        for acc in accounts {
            if !isValidETHAddress(address: acc) {
                fatalError("Invalid account address: \(acc)")
            }
        }
        let options = PushChat.UpdateGroupMemberOptions(
            account: account,
            chatId: chatId,
            upsert: PushChat.UpsertData(members: accounts),
            pgpPrivateKey: decryptedPgpPvtKey)
        return try await PushChat.updateGroupMember(options: options, env: env)
    }

    public func modify(chatId: String, role: GroupRoles, accounts: [String]) async throws -> PushChat.PushGroupInfoDTO? {
        if accounts.isEmpty {
            fatalError("accounts array cannot be empty!")
        }

        for acc in accounts {
            if !isValidETHAddress(address: acc) {
                fatalError("Invalid account address: \(acc)")
            }
        }

        let options = PushChat.UpdateGroupMemberOptions(
            account: account,
            chatId: chatId,
            upsert: role == .MEMBER ? PushChat.UpsertData(members: accounts) : PushChat.UpsertData(admins: accounts),
            pgpPrivateKey: decryptedPgpPvtKey)
        return try await PushChat.updateGroupMember(options: options, env: env)
    }

    public func info(chatId: String) async throws -> PushChat
        .PushGroupInfoDTO {
        return try await PushChat.getGroupInfoDTO(chatId: chatId, env: env)
    }

    public struct GroupCreationOptions {
        let description: String
        let image: String
        let members: [String]
        let admins: [String]
        let isPrivate: Bool
        let rules: Data?

        public init(description: String,
                    image: String,
                    members: [String] = [],
                    admins: [String] = [],
                    isPrivate: Bool = false,
                    rules: Data? = nil) {
            self.description = description
            self.image = image
            self.members = members
            self.admins = admins
            self.isPrivate = isPrivate
            self.rules = rules
        }
    }

    public func create(name: String, options: GroupCreationOptions) async throws -> PushChat.PushGroupInfoDTO? {
        let createGroupOptions = try PushChat.CreateGroupOptions(
            name: name,
            description: options.description,
            image: options.image,
            members: options.members,
            isPublic: !options.isPrivate,
            creatorAddress: account,
            creatorPgpPrivateKey: decryptedPgpPvtKey,
            env: env
        )

        return try await PushChat.createGroup(options: createGroupOptions)
    }
}

public struct GroupParticipants {
    private var env: ENV

    public init(env: ENV) {
        self.env = env
    }

    public struct FilterOptions {
        var pending: Bool?
        var role: String?

        /// role: 'admin' | 'member';
        public init(pending: Bool? = nil, role: String? = nil) {
            self.pending = pending
            self.role = role
        }
    }

    public struct GetGroupParticipantsOptions {
        var page: Int
        var limit: Int
        var filter: FilterOptions?

        public init(page: Int = 1, limit: Int = 20, filter: FilterOptions? = nil) {
            self.page = page
            self.limit = limit
            self.filter = filter
        }
    }

    public struct GroupCountInfo {
        public var participants: Int
        public var pending: Int

        public init(participants: Int, pending: Int) {
            self.participants = participants
            self.pending = pending
        }
    }

    public struct ParticipantStatus {
        public var pending: Bool
        public var role: String
        public var participant: Bool

        public init(pending: Bool, role: String, participant: Bool) {
            self.pending = pending
            self.role = role
            self.participant = participant
        }
    }

    public func list(chatId: String, options: GetGroupParticipantsOptions = GetGroupParticipantsOptions()) async throws -> [PushChat.ChatMemberProfile]? {
        let fetchOption = PushChat.FetchChatGroupInfo(
            chatId: chatId,
            limit: options.limit,
            pending: options.filter?.pending,
            role: options.filter?.role)
        return try await PushChat.getGroupMembers(options: fetchOption, env: env)
    }

    public func count(chatId: String) async throws -> GroupCountInfo {
        let count = try await PushChat.getGroupMemberCount(chatId: chatId, env: env)

        return GroupCountInfo(participants: count!.overallCount - count!.pendingCount, pending: count!.pendingCount)
    }

    public func status(chatId: String, accountId: String) async throws -> ParticipantStatus {
        let status = try await PushChat.getGroupMemberStatus(chatId: chatId, did: accountId, env: env)

        return ParticipantStatus(
            pending: status?.isPending == true,
            role: status?.isAdmin == true ? "ADMIN" : "MEMBER",
            participant: (status?.isMember ?? false) || (status?.isAdmin ?? false))
    }
}
