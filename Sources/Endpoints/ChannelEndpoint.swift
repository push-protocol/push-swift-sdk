import Foundation

extension PushEndpoint {
  static func getChannel(
    channel: String,
    env: ENV
  ) throws -> Self {
    return PushEndpoint(
      env: env,
      path: "channels/\(channel)"
    )
  }

  static func getOptIn(channel: String, env: ENV) throws -> Self {
    return PushEndpoint(
      env: env,
      path: "channels/\(channel)/subscribe"
    )
  }

  static func getOptOut(channel: String, env: ENV) throws -> Self {
    return PushEndpoint(
      env: env,
      path: "channels/\(channel)/unsubscribe"
    )
  }

  static func getSubscribers(channel: String, page:Int, limit:Int, env: ENV) throws -> Self {
    return PushEndpoint(
      env: env,
      path: "channels/\(channel)/subscribers",
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

  static func getChannels(page:Int, limit:Int, env: ENV) throws -> Self {
    return PushEndpoint(
      env: env,
      path: "channels",
      queryItems: [
        URLQueryItem(
          name: "page",
          value: String(page)
        ),
        URLQueryItem(
          name: "limit",
          value: String(limit)
        ),
        URLQueryItem(
          name: "sort",
          value: "subscribers"
        ),
        URLQueryItem(
          name: "order",
          value: "desc"
        ),
      ]
    )
  }

  static func getSearch(query:String,page:Int, limit:Int, env: ENV) throws -> Self {
    return PushEndpoint(
      env: env,
      path: "channels/search",
      queryItems: [
        URLQueryItem(
          name: "page",
          value: String(page)
        ),
        URLQueryItem(
          name: "limit",
          value: String(limit)
        ),
        URLQueryItem(
          name: "query",
          value:query
        ),
        URLQueryItem(
          name: "order",
          value: "desc"
        ),
      ]
    )
  }




  static func getIsSubscribed(env: ENV) throws -> URL {
    let endPoint = "https://"+ENV.getHost(withEnv: env) + "/apis/channels/_is_user_subscribed"
    return URL(string: endPoint)!
  }

}
