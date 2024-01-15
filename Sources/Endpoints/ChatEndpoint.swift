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
        )
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

}
