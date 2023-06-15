import Foundation

public struct PushEndpoint {
  var env: ENV
  var path: String
  var queryItems: [URLQueryItem] = []
}

extension PushEndpoint {
  var url: URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = ENV.getHost(withEnv: env)
    components.path = "/apis/v1/" + path
    components.queryItems = queryItems

    guard let url = components.url else {
      preconditionFailure(
        "Invalid URL components: \(components)"
      )
    }

    return url
  }
}

extension PushEndpoint {

  static func user(
    account userAddress: String,
    env: ENV
  ) -> Self {
    PushEndpoint(
      env: env,
      path: "users",
      queryItems: [
        URLQueryItem(
          name: "caip10",
          value: userAddress
        )
      ]
    )
  }

  static func updateUser(
    account userAddress: String,
    env: ENV
  ) -> URL {

    let endPoint = "https://" + ENV.getHost(withEnv: env) + "/apis/v2/users/\(userAddress)/profile"
    return URL(string: endPoint)!
  }

  static func getFeeds(
    options: PushUser.FeedsOptionsType,
    env: ENV
  ) throws -> Self {
    let userAddressCaip10 = try addressToCaip10(env: env, address: options.user)
    return PushEndpoint(
      env: env,
      path: "users/\(userAddressCaip10)/feeds",
      queryItems: [
        URLQueryItem(
          name: "page",
          value: String(options.page)
        ),
        URLQueryItem(
          name: "limit",
          value: String(options.limit)
        ),
        URLQueryItem(
          name: "spam",
          value: String(options.spam)
        ),
      ]
    )
  }

  static func createUser(env: ENV) -> Self {
    PushEndpoint(
      env: env,
      path: "users"
    )
  }

  static func getRequests(account: String, env: ENV, page: Int, limit: Int) -> Self {
    return PushEndpoint(
      env: env,
      path: "chat/users/\(account)/requests",
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
}
