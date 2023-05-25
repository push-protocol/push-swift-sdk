import web3

enum AddressError: Error {
  case InvalidAddress
}

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

public func getFallbackETHCAIPAddress(env: ENV, address: String) -> String {
  let chainId = env == ENV.PROD ? 1 : 5
  return "eip155:\(chainId):\(address)"
}

public func validateCAIP(env: ENV, address: String) -> Bool {
  let splittedAddress = address.split(separator: ":")
  if splittedAddress.count == 3 {
    if splittedAddress[0] == "eip155" {
      let chainId = env == ENV.PROD ? 1 : 5
      return splittedAddress[0] == "eip155" && splittedAddress[1] == String(chainId)
        && isValidETHAddress(address: String(splittedAddress[2]))
    }
  } else if splittedAddress.count == 2 {
    return splittedAddress[0] == "eip155" && isValidETHAddress(address: String(splittedAddress[1]))
  }
  return false
}

public func addressToCaip10(env: ENV, address: String) throws -> String {
  if validateCAIP(env: env, address: address) {
    return address
  }
  if isValidETHAddress(address: address) {
    return getFallbackETHCAIPAddress(env: env, address: address)
  }
  throw AddressError.InvalidAddress
}

public func pCAIP10ToWallet(address: String) -> String {
  return address.replacingOccurrences(of: "eip155:", with: "");
}

public func walletToPCAIP10(account: String) -> String {
  let splittedAddress = account.split(separator: ":");
  if(splittedAddress.count == 3) {
    return "eip155:" + splittedAddress[2];
  }
  if(account.contains("eip155:")) {
    return account;
  }
  return "eip155:\(account)";
}

public func getAccountAddress(wallet: walletType) async -> String {
  if(wallet.account != nil) {
    return wallet.account!
  }
  var address = ""
  if(wallet.signer != nil) {
    address = wallet.signer!.getAddress()
  }
  return address;
}

public func getUserDID(address: String) -> String {
  if(isValidETHAddress(address: address)) {
    return walletToPCAIP10(account: address);
  }
  return address;
}