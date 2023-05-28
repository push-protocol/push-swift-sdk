import Foundation

public struct User: Decodable {
  public let about: String?
  public let name: String?
  public let allowedNumMsg: Int
  public let did: String
  public let encryptedPrivateKey: String
  public let encryptionType: String
  public let encryptedPassword: String?
  public let nftOwner: String?
  public let numMsg: Int
  public let profilePicture: String
  public let publicKey: String
  public let sigType: String
  public let signature: String
  public let wallets: String
  public let linkedListHash: String?
  public let nfts: [String]?
}

extension User {
  public static func get(
    account userAddress: String,
    env: ENV
  ) async throws -> User? {
    let caipAddress = walletToPCAIP10(account: userAddress)
    let url = PushEndpoint.user(
      account: caipAddress,
      env: env
    ).url

    let (data, res) = try await URLSession.shared.data(from: url)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    //check if user is null
    if data.count == 4 {
      return nil
    }

    let userProfile = try JSONDecoder().decode(User.self, from: data)
    return userProfile

  }
}
