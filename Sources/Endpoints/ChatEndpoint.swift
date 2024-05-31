import Foundation

extension PushEndpoint {
    static func getChats(
        did: String,
        page: Int,
        limit: Int,
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/users/\(did)/chats",
            queryItems: [
                URLQueryItem(
                    name: "page",
                    value: String(page)
                ),
                URLQueryItem(
                    name: "limit",
                    value: String(limit)
                ),
            ]
        )
    }

    static func getConversationHash(
        converationId: String,
        account: String,
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/users/\(account)/conversations/\(converationId)/hash"
        )
    }

    static func getConversationHashReslove(
        threadHash: String,
        fetchLimit: Int,
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/conversationhash/\(threadHash)",
            queryItems: [
                URLQueryItem(
                    name: "fetchLimit",
                    value: "\(fetchLimit)"
                ),
            ]
        )
    }

    static func sendChatIntent(
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/request"
        )
    }

    static func sendChatMessage(
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/message"
        )
    }

    static func acceptChatRequest(
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/request/accept"
        )
    }

    static func createChatGroup(
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups",
            apiVersion: "v2"
        )
    }

    static func updatedChatGroup(
        chatId: String,
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)"
        )
    }

    static func getGroup(
        chatId: String,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)",
            apiVersion: apiVersion
        )
    }

    static func getGroupMemberCount(
        chatId: String,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)/members/count",
            apiVersion: apiVersion
        )
    }

    static func getGroupMemberStatus(
        chatId: String,
        did: String,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)/members/\(did)/status",
            apiVersion: apiVersion
        )
    }

    static func getGroupAccess(
        chatId: String,
        did: String,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)/access/\(did)",
            apiVersion: apiVersion
        )
    }

    static func getGroupSession(
        chatId: String,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/encryptedsecret/sessionKey/\(chatId)",
            apiVersion: apiVersion
        )
    }

    static func updateGroupMembers(
        chatId: String,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)/members",
            apiVersion: apiVersion
        )
    }

    static func getGroupMembers(
        options: PushChat.FetchChatGroupInfo,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        let path = "chat/groups/\(options.chatId)/members"

        var query = [URLQueryItem]()
        query.append(URLQueryItem(name: "pageNumber", value: "\(options.page)"))
        query.append(URLQueryItem(name: "pageSize", value: "\(options.limit)"))
        
        if options.pending != nil {
            query.append(URLQueryItem(name: "pending", value: "\(options.pending ?? false)"))
        }

        if options.role != nil {
            query.append(URLQueryItem(name: "role", value: "\(options.role ?? "")"))
        }
        return PushEndpoint(
            env: env,
            path: path,
            queryItems: query,
            apiVersion: apiVersion
        )
    }

    static func getGroupMembersPublicKeys(
        chatId: String,
        page: Int,
        limit: Int,
        apiVersion: String = "v1",
        env: ENV
    ) throws -> Self {
        return PushEndpoint(
            env: env,
            path: "chat/groups/\(chatId)/members/publicKeys?pageNumber=\(page)&pageSize=\(limit)",
            apiVersion: apiVersion
        )
    }
}
