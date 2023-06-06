import Foundation

extension PushChannel {

  public struct SearchsOptions {
    public let query: String
    public let page: Int
    public let limit: Int
    public let env: ENV

    public init(query: String, page: Int, limit: Int, env: ENV) {
      self.query = query
      self.page = page > 0 ? page : 1
      self.limit = limit > 30 ? 30 : limit
      self.env = env
    }
  }

  public static func search(option: SearchsOptions) async throws -> Channels {

    let url = try PushEndpoint.getSearch(
      query: option.query, page: option.page, limit: option.limit, env: option.env
    ).url

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode(Channels.self, from: data)

  }
}
