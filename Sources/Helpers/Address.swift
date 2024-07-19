import Foundation
import Web3Core

enum AddressError: Error {
    case InvalidAddress
}

public func isValidETHAddress(address: String) -> Bool {
    func isAddressValid(addrs: String) -> Bool {
        let addrs = EthereumAddress(addrs)

        if addrs == nil {
            return false
        }
        return true
    }
    if address.contains("eip155:") {
        let splittedAddress = address.split(separator: ":")
        if splittedAddress.count == 3 {
            return isAddressValid(addrs: String(splittedAddress[2]))
        }
        if splittedAddress.count == 2 {
            return isAddressValid(addrs: String(splittedAddress[1]))
        }
    }

    return isAddressValid(addrs: address)
}

public func getFallbackETHCAIPAddress(env: ENV, address: String) -> String {
    let chainId = env == ENV.PROD ? 1 : 5
    return "eip155:\(chainId):\(address)"
}

public func isGroupChatId(_ chatId: String) -> Bool {
    return chatId.count == 64
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
    if isGroupChatId(address) {
        return address
    }

    if validateCAIP(env: env, address: address) {
        return address
    }
    if isValidETHAddress(address: address) {
        return getFallbackETHCAIPAddress(env: env, address: address)
    }
    throw AddressError.InvalidAddress
}

public func addressesToCaip10(env: ENV, addresses: [String]) throws -> [String] {
    var _addresses: [String] = []

    for addrs in addresses {
        try _addresses.append(addressToCaip10(env: env, address: addrs))
    }

    return _addresses
}

public func pCAIP10ToWallet(address: String) -> String {
    if isGroupChatId(address) {
        return address
    }
    return address.replacingOccurrences(of: "eip155:", with: "")
}

public func walletToPCAIP10(account: String) -> String {
    if isGroupChatId(account) {
        return account
    }
    let splittedAddress = account.split(separator: ":")
    if splittedAddress.count == 3 {
        return "eip155:" + splittedAddress[2]
    }
    if account.contains("eip155:") {
        return account
    }
    return "eip155:\(account)"
}

public func walletsToPCAIP10(accounts: [String]) -> [String] {
    var _addresses: [String] = []

    for acc in accounts {
        _addresses.append(walletToPCAIP10(account: acc))
    }

    return _addresses
}

public func walletToCAIPEth(account: String, env: ENV) -> String {
    let splittedAddress = account.split(separator: ":")
    let chainId = env == ENV.PROD ? "1" : "5"
    if splittedAddress.count == 3 {
        return account
    }
    return "eip155:\(chainId):\(account)"
}

public func getUserDID(address: String) -> String {
    if isValidETHAddress(address: address) {
        return walletToPCAIP10(account: address)
    }
    return address
}
