import Foundation

public struct PushUser: Decodable {

  public enum UserError: Error {
    case ONE_OF_ACCOUNT_OR_SIGNER_REQUIRED
    case INVALID_ETH_ADDRESS
    case USER_NOT_CREATED
    case RUNTIME_ERROR(String)
  }

  public struct PGPPublicKey: Decodable {
    public let key: String
    public let signature: String
  }

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
  public let blockedUsersList: [String]?

  public func getPGPPublickey() -> String {
    return PushUser.getPGPPublickey(publicKey: self.publicKey)
  }

  public static func getPGPPublickey(publicKey: String) -> String {
    do {
      return try JSONDecoder().decode(PGPPublicKey.self, from: publicKey.data(using: .utf8)!)
        .key

    } catch {
      return publicKey
    }
  }
}

extension PushUser {
  public static func get(
    account userAddress: String,
    env: ENV
  ) async throws -> PushUser? {
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

    let userProfile = try JSONDecoder().decode(PushUser.self, from: data)
    return userProfile

  }

  public static func userProfileCreated(account: String, env: ENV) async throws -> Bool {
    let userInfo = try await PushUser.get(account: account, env: env)
    return userInfo != nil
  }
}
