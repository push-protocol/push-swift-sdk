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

}
