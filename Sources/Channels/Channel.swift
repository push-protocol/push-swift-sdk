import Foundation

public struct PushChannel: Codable {
  public let id: Int
  public let channel: String
  public let ipfshash: String
  public let name: String
  public let info: String
  public let url: String
  public let icon: String
  public let processed: Int
  public let attempts: Int
  public let alias_address: String
  public let alias_verification_event: String?
  public let is_alias_verified: Int
  public let alias_blockchain_id: String
  public let activation_status: Int
  public let verified_status: Int
  public let timestamp: String
  public let blocked: Int
  public let counter: Int?
  public let subgraph_details: String?
  public let subgraph_attempts: Int
}

extension PushChannel {
  public struct GetChannelOption {
    let channel: String
    let env: ENV

    public init(channel: String, env: ENV) {
      self.channel = walletToCAIPEth(account: channel, env: env)
      self.env = env
    }

  }

  public static func getChannel(
    options: GetChannelOption
  ) async throws -> PushChannel? {

    let url = try PushEndpoint.getChannel(channel: options.channel, env: options.env).url

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    if httpResponse.statusCode == 404 {
      return nil
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    do {
      return try JSONDecoder().decode(PushChannel.self, from: data)
    } catch {
      return nil
    }

  }

  public static func getChannels(option: GetChannelsOptions) async throws -> Channels {

    let url = try PushEndpoint.getChannels(page: option.page, limit: option.limit, env: option.env)
      .url

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
