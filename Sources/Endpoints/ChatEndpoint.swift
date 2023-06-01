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

}
