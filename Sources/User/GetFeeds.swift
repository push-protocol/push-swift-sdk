import Foundation

public struct AdditionalMeta: Codable {
  public let type: String
  public let data: String
  public let domain: String?
}

public enum AdditionalMetaEnum: Codable {
  case string(String)
  case additionalMeta(AdditionalMeta)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode(AdditionalMeta.self) {
      self = .additionalMeta(value)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Invalid additionalMeta value")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .additionalMeta(let value):
      try container.encode(value)
    }
  }
}

public enum Recipients: Codable {
  case string(String)
  case stringArray([String])

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode([String].self) {
      self = .stringArray(value)
    } else {
      throw DecodingError.dataCorruptedError(
        in: container, debugDescription: "Invalid recipients value")
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .string(let value):
      try container.encode(value)
    case .stringArray(let value):
      try container.encode(value)
    }
  }
}

public struct PayloadData: Codable {
  public let app: String
  public let sid: String
  public let url: String
  public let acta: String
  public let aimg: String
  public let amsg: String
  public let asub: String
  public let icon: String
  public let type: Int
  public let epoch: String
  public let etime: String?
  public let hidden: String?
  public let secret: String?
  public let sectype: String?
  public let additionalMeta: AdditionalMetaEnum?
}

public struct Notification: Codable {
  public let body: String
  public let title: String
}

public struct Payload: Codable {
  public let data: PayloadData
  public let recipients: Recipients?
  public let notification: Notification
  public let verificationProof: String
  public let source: String?
  public let etime: String?
}

public struct UserFeeds: Codable {
  public let payload_id: Int
  public let sender: String
  public let epoch: String
  public let payload: Payload
}

public struct FeedResponse: Codable {
  public let feeds: [UserFeeds]
  public let itemcount: Int
}

public struct FeedsOptionsType {
  var user: String
  var chainId: Int = CONSTANTS.DEFAULT_CHAIN_ID
  var env: ENV = ENV.STAGING
  var page: Int = CONSTANTS.PAGINATION.INITIAL_PAGE
  var spam: Bool = false
  var limit: Int = CONSTANTS.PAGINATION.LIMIT

  public init(
    user: String,
    chainId: Int = CONSTANTS.DEFAULT_CHAIN_ID,
    env: ENV = ENV.STAGING,
    page: Int = CONSTANTS.PAGINATION.INITIAL_PAGE,
    spam: Bool = false,
    limit: Int = CONSTANTS.PAGINATION.LIMIT
  ) {
    self.user = user
    self.chainId = chainId
    self.env = env
    self.page = page
    self.spam = spam
    self.limit = limit
  }
}

extension User {
  public static func getFeeds(
    options: FeedsOptionsType
  ) async throws -> FeedResponse {
    let url: URL = try PushEndpoint.getFeeds(
      options: options,
      env: options.env
    ).url

    let (data, res) = try await URLSession.shared.data(from: url)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    if data.count == 4 {
      return FeedResponse(feeds: [], itemcount: 0)
    }

    do {
      let jsonData = Data(data)
      let dataContainer = try JSONDecoder().decode(FeedResponse.self, from: jsonData)
      return dataContainer
    } catch {
      print("[Push SDK] - API : \(error.localizedDescription)")
      throw error
    }
  }
}
