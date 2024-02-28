import Foundation

extension PushChat {
  public static func getGroup(chatId: String, env: ENV) async throws -> PushChat.PushGroup? {
    let url = try PushEndpoint.getGroup(chatId: chatId, env: env).url
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, res) = try await URLSession.shared.data(for: request)
    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    if httpResponse.statusCode == 400 {
      return nil
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let groupData = try JSONDecoder().decode(PushGroup.self, from: data)
    return groupData
  }

  public static func getGroupInfoDTO(chatId: String, env: ENV) async throws -> PushChat
    .PushGroupInfoDTO
  {
    let url = try PushEndpoint.getGroup(chatId: chatId, apiVersion: "v2", env: env).url
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (data, res) = try await URLSession.shared.data(for: request)
    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    if httpResponse.statusCode == 400 {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let groupData = try JSONDecoder().decode(PushGroupInfoDTO.self, from: data)
    return groupData
  }

  public static func getGroupSessionKey(sessionKey: String, env: ENV) async throws -> String {
    let url = try PushEndpoint.getGroupSession(chatId: sessionKey, apiVersion: "v1", env: env).url
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

    struct SecretSessionRes: Codable {
      var encryptedSecret: String
    }

    let groupData = try JSONDecoder().decode(SecretSessionRes.self, from: data)

    return groupData.encryptedSecret
  }

}
