import web3

public struct Singer {
  let account: EthereumAccount

  public init(privateKey: String) {
    let keyStorage = EthereumKeyLocalStorage()
    let account = try! EthereumAccount.importAccount(
      addingTo: keyStorage, privateKey: privateKey, keystorePassword: privateKey)
    self.account = account
  }

  public func getEip191Signature(message: String) throws -> String {
    let data = message.data(using: .utf8)!
    let msg = try account.signMessage(message: data)
    return msg
  }

}
