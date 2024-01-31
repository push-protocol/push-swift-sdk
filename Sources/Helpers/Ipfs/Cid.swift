import Foundation

public struct Message: Codable {
  public var fromCAIP10: String
  public var toCAIP10: String
  public var fromDID: String
  public var toDID: String
  public var messageType: String
  public var messageContent: String
  public var messageObj: String?
  public var signature: String
  public var sigType: String
  public var timestamp: Int?
  public var encType: String
  public var encryptedSecret: String?
  public var link: String?
  public var cid: String?
  public var sessionKey: String?
}

public func getCID(env: ENV, cid: String) async throws -> Message {
  let url: URL = PushEndpoint.getCID(env: env, cid: cid).url
  print("this url is \(url)")

  let (data, res) = try await URLSession.shared.data(from: url)

  guard let httpResponse = res as? HTTPURLResponse else {
    throw URLError(.badServerResponse)
  }

  guard (200...299).contains(httpResponse.statusCode) else {
    print(res)
    throw URLError(.badServerResponse)
  }

  do {
    return try JSONDecoder().decode(Message.self, from: data)
  } catch {
    print("[Push SDK] - API \(error.localizedDescription)")
    throw error
  }
}
