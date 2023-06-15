import Foundation

public struct PushChat {
  public struct Feeds: Decodable {
    public var msg: Message?
    public var did: String?
    public var wallets: String?
    public var profilePicture: String?
    public var publicKey: String?
    public var about: String?
    public var name: String?
    public var threadhash: String?
    public var intent: String?
    public var intentSentBy: String?
    public var intentTimestamp: String?
    public var combinedDID: String
    public var cid: String?
    public var chatId: String?
    public var deprecated: Bool?
    public var deprecatedCode: String?
  }

  public struct GetChatsOptions {
    var account: String
    var pgpPrivateKey: String?
    var toDecrypt: Bool = false
    var page: Int = CONSTANTS.PAGINATION.INITIAL_PAGE
    var limit: Int = CONSTANTS.PAGINATION.LIMIT
    var env: ENV = ENV.STAGING

    public init(
      account: String,
      pgpPrivateKey: String?,
      toDecrypt: Bool = false,
      page: Int = CONSTANTS.PAGINATION.INITIAL_PAGE,
      limit: Int = CONSTANTS.PAGINATION.LIMIT,
      env: ENV = ENV.STAGING
    ) {
      self.account = account
      self.pgpPrivateKey = pgpPrivateKey
      self.toDecrypt = toDecrypt
      self.page = page
      self.limit = limit
      self.env = env
    }
  }

  public struct GetChatsResponse: Decodable {
    var chats: [Feeds]
  }

  enum ChatError: Error {
    case invalidAddress
    case decryptedPrivateKeyNecessary
    case chatError(String)
  }

  public static func getChats(options: GetChatsOptions) async throws -> [Feeds] {
    if !isValidETHAddress(address: options.account) {
      throw ChatError.invalidAddress
    }
    let user = getUserDID(address: options.account)

    let url = try PushEndpoint.getChats(
      did: user,
      page: options.page,
      limit: options.limit,
      env: options.env
    ).url

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      let response = try JSONDecoder().decode(GetChatsResponse.self, from: data)
      // TODO:
      let feeds: [Feeds] = try await getInboxLists(
        chats: response.chats,
        user: user,
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
