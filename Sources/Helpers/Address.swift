import Web3

public func isValidETHAddress(address: String) -> Bool {
  do {
    // TODO: support later
    // if isValidCAIP10NFTAddress(wallet:address) {
    //     return true
    // }
    if address.contains("eip155:") {
      let splittedAddress = address.split(separator: ":")
      if splittedAddress.count == 3 {
        _ = try EthereumAddress(hex: String(splittedAddress[2]), eip55: true)
        return true

      }
      if splittedAddress.count == 2 {
        _ = try EthereumAddress(hex: String(splittedAddress[1]), eip55: true)
        return true
      }
    }

    _ = try EthereumAddress(hex: address, eip55: true)
    return true
  } catch {

    return false
  }
}
