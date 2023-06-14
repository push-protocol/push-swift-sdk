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

}
