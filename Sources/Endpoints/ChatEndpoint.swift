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
        )
      ]
    )
  }
}
