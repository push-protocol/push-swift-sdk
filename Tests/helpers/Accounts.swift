import CryptoKit
import Web3Core
import XCTest

public func getRandomAccount() -> String {
  let length = 64
  let letters = "abcdef0123456789"
  let privateKey = String((0..<length).map { _ in letters.randomElement()! })

  return privateKey
}

public func generateRandomEthereumAddress() -> String {
  let characters = "abcdef0123456789"
  let charactersCount = UInt32(characters.count)
  var randomString = ""

  for _ in 0..<40 {
    let randomIndex = Int(arc4random_uniform(charactersCount))
    let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
    randomString += String(randomCharacter)
  }

  let address = "0x" + randomString
  let ethAddress = EthereumAddress(address, type: .normal, ignoreChecksum: true)!

  return ethAddress.address
}
