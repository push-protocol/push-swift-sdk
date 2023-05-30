import web3swift
import Web3Core

import Foundation
import CryptoSwift

public protocol Signer {
  func getEip191Signature(message: String) async throws -> String
  func getAddress() async throws -> String
}

public struct SignerPrivateKey: Signer {
  let account:EthereumKeystoreV3 

  public init(privateKey: String) throws{
     let keystore =  try EthereumKeystoreV3(privateKey: Data.fromHex(privateKey)!, password: "DADDA")!
     self.account = keystore
  }

  public func getEip191Signature(message: String) async throws -> String {
      let messageData = message.data(using: .utf8)!
      let sig = try Web3Signer.signPersonalMessage(messageData, keystore: account,account: account.getAddress()!, password: "DADDA")!
      return "0x" + sig.map { String(format: "%02x", $0) }.joined()
  }

  public func getAddress() async throws -> String {
    // return account.address.hex(eip55: true)
    let ethAddress = account.getAddress()!
    return ethAddress.address  
  }
}