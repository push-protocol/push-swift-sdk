import web3

public struct Signer {
  let account: EthereumAccount

  public init(privateKey: String) {
    let keyStorage = EthereumKeyLocalStorage()
    let account = try! EthereumAccount.importAccount(
      addingTo: keyStorage, privateKey: privateKey, keystorePassword: privateKey)
    self.account = account
  }

  public func getEip191Signature(message: String, version: String = "v2") throws -> String {
    let data = message.data(using: .utf8)!
    let signature = try account.signMessage(message: data)
    let sigType = version == "v1" ? "eip191" : "eip191v2"
    return "\(sigType):\(signature)"
  }

  public func getAddress() -> String {
    return account.address.asString();
  }
}
