import CryptoSwift
import Foundation

public protocol Signer {
  func getEip191Signature(message: String) async throws -> String
  func getAddress() async throws -> String
}

public protocol TypedSinger {
  func getEip712Signature(message: String)
    async throws -> String
  func getAddress() async throws -> String
}
