import CryptoSwift
import Foundation
import Push
import Web3Core
import web3swift

public struct SignerPrivateKey: Push.Signer {
  let account: EthereumKeystoreV3

  public init(privateKey: String) throws {
    let keystore = try EthereumKeystoreV3(privateKey: Data.fromHex(privateKey)!, password: "")!
    self.account = keystore
  }

  public func getEip191Signature(message: String) async throws -> String {
    let messageData = message.data(using: .utf8)!
    let sig = try Web3Signer.signPersonalMessage(
      messageData, keystore: account, account: account.getAddress()!, password: "")!
    return "0x" + sig.map { String(format: "%02x", $0) }.joined()
  }

  public func getAddress() async throws -> String {
    // return account.address.hex(eip55: true)
    let ethAddress = account.getAddress()!
    return ethAddress.address
  }
}

public struct MockEIP712OptinSigner: TypedSigner {
  public func getEip712Signature(message: String)
    async throws -> String
  {
    // optin
    //channel    eip155:5:0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78
    //subscriber eip155:5:0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c
    return
      "0xbd2724da36cbb3a99d59d4133b9cceb6a602bb1c0aab69d249a199c071a196880e8b7fba882cb10e943223be2ce34ccc5ceb4e1326410e968cd4497748c0de111c"
  }

  public func getAddress() async throws -> String {
    return "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
  }
}

public struct MockEIP712OptoutSigner: TypedSigner {
  public func getEip712Signature(message: String)
    async throws -> String
  {
    // optout
    //channel    eip155:5:0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78
    //subscriber eip155:5:0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c
    return
      "0xac77e24153f6b5a46b42020ba987d402c4b5b0308aa62cf06cd2a9173c3c613d4d182bba1607d004a504848cebe30b73c9efb88897e0f9563f38e21ec2e84b281b"
  }

  public func getAddress() async throws -> String {
    return "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
  }
}
