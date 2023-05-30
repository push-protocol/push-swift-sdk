import Web3

public protocol Signer {
  func getEip191Signature(message: String) async throws -> String
  func getAddress() async throws -> String
}

public struct SignerPrivateKey: Signer {
  let account: EthereumPrivateKey

  public init(privateKey: String) {
    var pk = privateKey
    if !privateKey.hasPrefix("0x") {
      pk = "0x" + privateKey
    }

    let privateKey = try! EthereumPrivateKey(hexPrivateKey:pk)
    self.account = privateKey
  }

  public func getEip191Signature(message: String) async throws -> String {
    print("\n\ncalled\n\n")
    
    let data = message.data(using: .utf8)!
    let (v,r,s) = try account.sign(message: data.bytes)

    print(v,r,s)

    return "0x"
  }

  public func getAddress() async throws -> String {
    return account.address.hex(eip55: true)
  }
}