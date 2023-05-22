import web3

public func isValidETHAddress(address: String) -> Bool {
  // TODO: support later
  // if isValidCAIP10NFTAddress(wallet:address) {
  //     return true
  // }
  if address.contains("eip155:") {
    let splittedAddress = address.split(separator: ":")
    if splittedAddress.count == 3 {
      return splittedAddress[2] == EthereumAddress(String(splittedAddress[2])).toChecksumAddress()
    }
    if splittedAddress.count == 2 {
      return splittedAddress[1] == EthereumAddress(String(splittedAddress[1])).toChecksumAddress()
    }
  }

  return address == EthereumAddress(address).toChecksumAddress()
}