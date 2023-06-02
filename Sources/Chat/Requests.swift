import Foundation

extension PushChat {

  /// The first time an address wants to send a message to another peer, the address sends an intent request. This first message shall not land in this peer Inbox but in its Request box.
  /// This function will return all the chats that landed on the address' Request box. The user can then approve the request or ignore it for now.
  public struct RequestOptionsType {
    let account: String
    let env: ENV
    let page: Int
    let limit: Int
    let pgpPrivateKey: String
    let toDecrypt: Bool

    public init(
      account: String, pgpPrivateKey: String, toDecrypt: Bool = true, page: Int = 1, limit: Int = 5,
      env: ENV = .STAGING
    ) {
      self.account = walletToPCAIP10(account: account)
      self.pgpPrivateKey = pgpPrivateKey
      self.env = env
      self.page = page
      self.limit = limit
      self.toDecrypt = toDecrypt
    }
  }

  public struct GetRequestsResponse: Decodable {
    var requests: [Feeds]
  }

  public static func requests(
    options: RequestOptionsType
  ) async throws -> [Feeds] {

    let url = PushEndpoint.getRequests(
      account: options.account, env: options.env, page: options.page, limit: options.limit
    ).url

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let response = try JSONDecoder().decode(GetRequestsResponse.self, from: data)

      let feeds: [Feeds] = try await getInboxLists(
        chats: response.requests,
        user: options.account,
        toDecrypt: options.toDecrypt,
        pgpPrivateKey: options.pgpPrivateKey,
        env: options.env
      )
      return feeds
    } catch {
      print("error: \(error)")
      throw error
    }

  }
}
