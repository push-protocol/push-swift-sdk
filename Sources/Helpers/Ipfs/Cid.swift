import Foundation

public struct Message: Codable {
  public let fromCAIP10: String
  public let toCAIP10: String
  public let fromDID: String
  public let toDID: String
  public let messageType: String
  public let messageContent: String
  public let signature: String
  public let sigType: String
  public let timestamp: Int?
  public let encType: String
  public let encryptedSecret: String
  public let link: String?
}

public func getCID(env: ENV, cid: String) async throws -> Message {
  let url: URL = PushEndpoint.getCID(env: env, cid: cid).url
  let (data, res) = try await URLSession.shared.data(from: url)

  guard let httpResponse = res as? HTTPURLResponse else {
    throw URLError(.badServerResponse)
  }

  guard (200...299).contains(httpResponse.statusCode) else {
    throw URLError(.badServerResponse)
  }

  do {
    return try JSONDecoder().decode(Message.self, from: data)
  } catch {
    print("[Push SDK] - API \(error.localizedDescription)")
    throw error
  }
}
