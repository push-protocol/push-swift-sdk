import web3

public protocol Signer {
  func getEip191Signature(message: String) async throws -> String
  func getAddress() async throws -> String
}

public struct SignerPrivateKey: Signer {
  let account: EthereumAccount

  public init(privateKey: String) {
    let keyStorage = EthereumKeyLocalStorage()
    let account = try! EthereumAccount.importAccount(
      addingTo: keyStorage, privateKey: privateKey, keystorePassword: privateKey)
    self.account = account
  }

  public func getEip191Signature(message: String) async throws -> String {
    let data = message.data(using: .utf8)!
    let signature = try account.signMessage(message: data)
    return signature
  }

  public func getAddress() async throws -> String {
    return account.address.toChecksumAddress()
  }
}
