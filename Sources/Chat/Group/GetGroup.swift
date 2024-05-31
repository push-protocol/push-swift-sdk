import Foundation

extension PushChat {
    public static func getGroup(chatId: String, env: ENV) async throws -> PushChat.PushGroup? {
        let url = try PushEndpoint.getGroup(chatId: chatId, env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let groupData = try JSONDecoder().decode(PushGroup.self, from: data)
        return groupData
    }

    public static func getGroupInfoDTO(chatId: String, env: ENV) async throws -> PushChat
        .PushGroupInfoDTO {
        let url = try PushEndpoint.getGroup(chatId: chatId, apiVersion: "v2", env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            throw URLError(.badServerResponse)
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let groupData = try JSONDecoder().decode(PushGroupInfoDTO.self, from: data)
        return groupData
    }

    public static func getGroupSessionKey(sessionKey: String, env: ENV) async throws -> String {
        let url = try PushEndpoint.getGroupSession(chatId: sessionKey, apiVersion: "v1", env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        struct SecretSessionRes: Codable {
            var encryptedSecret: String
        }

        let groupData = try JSONDecoder().decode(SecretSessionRes.self, from: data)

        return groupData.encryptedSecret
    }

    public static func getGroupAccess(chatId: String, did: String, env: ENV) async throws -> GroupAccess? {
        let url = try PushEndpoint.getGroupAccess(chatId: chatId, did: did, env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(GroupAccess.self, from: data)
    }

    public static func getGroupMemberCount(chatId: String, env: ENV) async throws -> TotalMembersCount? {
        let url = try PushEndpoint.getGroupMemberCount(chatId: chatId, env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let groupData = try JSONDecoder().decode(ChatMemberCounts.self, from: data)
        return groupData.totalMembersCount
    }

    public static func getGroupMemberStatus(chatId: String, did: String, env: ENV) async throws -> GroupMemberStatus? {
        let url = try PushEndpoint.getGroupMemberStatus(chatId: chatId, did: walletToPCAIP10(account: did), env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let groupData = try JSONDecoder().decode(GroupMemberStatus.self, from: data)
        return groupData
    }

    public struct FetchChatGroupInfo {
        var chatId: String
        var page: Int
        var limit: Int
        var pending: Bool?
        var role: String?

        init(chatId: String, page: Int = 1, limit: Int = 20, pending: Bool? = nil, role: String? = nil) {
            self.chatId = chatId
            self.page = page
            self.limit = limit
            self.pending = pending
            self.role = role
        }
    }

    public static func getGroupMembers(options: FetchChatGroupInfo, env: ENV) async throws -> [ChatMemberProfile]? {
        let url = try PushEndpoint.getGroupMembers(options: options, env: env).url
        var request = URLRequest(url: url)        
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let groupData = try JSONDecoder().decode(GetMembersResponse.self, from: data)
        return groupData.members
    }

    public static func getGroupMembersPublicKeys(chatId: String, page: Int = 1, limit: Int = 20, env: ENV) async throws -> [GroupMemberPublicKey]? {
        let url = try PushEndpoint.getGroupMembersPublicKeys(chatId: chatId, page: page, limit: limit, env: env).url
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, res) = try await URLSession.shared.data(for: request)
        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        if httpResponse.statusCode == 400 {
            return nil
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        let groupData = try JSONDecoder().decode(GetMemberPublicKeysResponse.self, from: data)
        return groupData.members
    }

    public static func getAllGroupMembersPublicKeysV2(chatId: String, env: ENV) async throws -> [GroupMemberPublicKey]? {
        let count = try await getGroupMemberCount(chatId: chatId, env: env)
        let limit = 5000

        let totalPages = Int(ceil(Double(count?.overallCount ?? 0) / Double(limit)))
        var members = [GroupMemberPublicKey]()

        for i in 1 ..< totalPages {
            let page = try await getGroupMembersPublicKeys(chatId: chatId, page: i, limit: limit, env: env)
            members = members + (page ?? [])
        }

        return members
    }
}
