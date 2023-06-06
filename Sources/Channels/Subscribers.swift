import Foundation

extension PushChannel {
  public struct GetChannelSubscribersOptions {
    public let channel: String
    public let page: Int
    public let limit: Int
    public let env: ENV

    public init(channel: String, page: Int, limit: Int, env: ENV) {
      self.channel = channel
      self.page = page > 0 ? page : 1
      self.limit = limit > 30 ? 30 : limit
      self.env = env
    }
  }

  public struct GetChannelsOptions {
    public let page: Int
    public let limit: Int
    public let env: ENV

    public init(page: Int, limit: Int, env: ENV) {
      self.page = page > 0 ? page : 1
      self.limit = limit > 30 ? 30 : limit
      self.env = env
    }
  }

  public struct ChannelSubscribers: Codable {
    public let itemcount: Int
    public let subscribers: [String]
  }

  public struct Channels: Codable {
    public let channels: [PushChannel]
    public let itemcount: Int
  }

  public static func getSubscribers(option: GetChannelSubscribersOptions) async throws
    -> ChannelSubscribers
  {
    let _channel = walletToCAIPEth(account: option.channel, env: option.env)

    let url = try PushEndpoint.getSubscribers(
      channel: _channel, page: option.page, limit: option.limit, env: option.env
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

    return try JSONDecoder().decode(ChannelSubscribers.self, from: data)

  }

  public static func getIsSubscribed(userAddress: String, channelAddress: String, env: ENV)
    async throws -> Bool
  {

    struct RequestStruct: Codable {
      let subscriber: String
      let channel: String
      let op: String
    }

    let requestBody = RequestStruct(subscriber: userAddress, channel: channelAddress, op: "read")

    let url = try PushEndpoint.getIsSubscribed(env: env)
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, res) = try await URLSession.shared.data(for: request)
    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let result = try JSONDecoder().decode(Bool.self, from: data)
    return result

  }

}
