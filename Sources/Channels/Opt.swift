import Foundation

extension PushChannel {
  public static func getOptInMessage(channel: String, subscriber: String, env: ENV) -> String {
    let _channel = channel.lowercased()
    let _subscriber = subscriber.lowercased()
    var _chainId = 5

    if env == ENV.PROD {
      _chainId = 1
    }

    return
      "{\"types\":{\"Subscribe\":[{\"name\":\"channel\",\"type\":\"address\"},{\"name\":\"subscriber\",\"type\":\"address\"},{\"name\":\"action\",\"type\":\"string\"}],\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}]},\"primaryType\":\"Subscribe\",\"domain\":{\"name\":\"EPNS COMM V1\",\"chainId\":\(_chainId),\"verifyingContract\":\"0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa\"},\"message\":{\"channel\":\"\(_channel)\",\"subscriber\":\"\(_subscriber)\",\"action\":\"Subscribe\"}}"
  }

  public static func getOptOutMessage(channel: String, subscriber: String, env: ENV) -> String {
    let _channel = channel.lowercased()
    let _subscriber = subscriber.lowercased()
    var _chainId = 5

    if env == ENV.PROD {
      _chainId = 1
    }

    return
      "{\"types\":{\"Unsubscribe\":[{\"name\":\"channel\",\"type\":\"address\"},{\"name\":\"unsubscriber\",\"type\":\"address\"},{\"name\":\"action\",\"type\":\"string\"}],\"EIP712Domain\":[{\"name\":\"name\",\"type\":\"string\"},{\"name\":\"chainId\",\"type\":\"uint256\"},{\"name\":\"verifyingContract\",\"type\":\"address\"}]},\"primaryType\":\"Unsubscribe\",\"domain\":{\"name\":\"EPNS COMM V1\",\"chainId\":\(_chainId),\"verifyingContract\":\"0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa\"},\"message\":{\"channel\":\"\(_channel)\",\"unsubscriber\":\"\(_subscriber)\",\"action\":\"Unsubscribe\"}}"
  }

  public struct SubscribeOption {
    let signer: TypedSinger
    let channelAddress: String
    let env: ENV

    public init(
      signer: TypedSinger,
      channelAddress: String,
      env: ENV
    ) {
      self.signer = signer
      self.channelAddress = channelAddress
      self.env = env
    }
  }

  public static func subscribe(option: SubscribeOption) async throws -> Bool {

    let userAddress = try await option.signer.getAddress()

    // get payload ready
    let messageToSign = PushChannel.getOptInMessage(
      channel: option.channelAddress,
      subscriber: userAddress,
      env: option.env
    )
    let verificationProof = try await option.signer.getEip712Signature(message: messageToSign)
    let channelAddressCAIP = walletToCAIPEth(account: option.channelAddress, env: option.env)
    let userAddressCAIP = walletToCAIPEth(account: userAddress, env: option.env)
    let requestBody = OptRequest.optRequest(
      verificationProof: verificationProof,
      channel: channelAddressCAIP,
      subscriber: userAddressCAIP,
      optIn: true
    )

    // make the request
    let url = try PushEndpoint.getOptIn(channel: channelAddressCAIP, env: option.env).url
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (_, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let isIsSubscribed = try await PushChannel.getIsSubscribed(
      userAddress: userAddress, channelAddress: option.channelAddress, env: option.env)

    let success = isIsSubscribed == true
    return success
  }

  public static func unsubscribe(option: SubscribeOption) async throws -> Bool {

    let userAddress = try await option.signer.getAddress()

    // get payload ready
    let messageToSign = PushChannel.getOptOutMessage(
      channel: option.channelAddress,
      subscriber: userAddress,
      env: option.env
    )
    let verificationProof = try await option.signer.getEip712Signature(message: messageToSign)
    let channelAddressCAIP = walletToCAIPEth(account: option.channelAddress, env: option.env)
    let userAddressCAIP = walletToCAIPEth(account: userAddress, env: option.env)
    let requestBody = OptRequest.optRequest(
      verificationProof: verificationProof,
      channel: channelAddressCAIP,
      subscriber: userAddressCAIP,
      optIn: false
    )

    // make the request
    let url = try PushEndpoint.getOptOut(channel: channelAddressCAIP, env: option.env).url
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = try JSONEncoder().encode(requestBody)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    let (_, res) = try await URLSession.shared.data(for: request)

    guard let httpResponse = res as? HTTPURLResponse else {
      throw URLError(.badServerResponse)
    }

    guard (200...299).contains(httpResponse.statusCode) else {
      throw URLError(.badServerResponse)
    }

    let isIsSubscribed = try await PushChannel.getIsSubscribed(
      userAddress: userAddress, channelAddress: option.channelAddress, env: option.env)

    let success = isIsSubscribed == false
    return success
  }
}

struct OptMessage: Codable {
  let action: String
  let channel: String
  let subscriber: String?
  let unsubscriber: String?

  public static func getOptInMessage(channel: String, subscriber: String) -> Self {
    return OptMessage(
      action: "Subscribe", channel: channel, subscriber: subscriber, unsubscriber: nil)
  }

  public static func getOptOutMessage(channel: String, subscriber: String) -> Self {
    return OptMessage(
      action: "Unsubscribe", channel: channel, subscriber: nil, unsubscriber: subscriber)
  }
}

struct OptRequest: Codable {
  let verificationProof: String
  let message: OptMessage

  public static func optRequest(
    verificationProof: String, channel: String, subscriber: String, optIn: Bool
  ) -> Self {
    let message =
      optIn
      ? OptMessage.getOptInMessage(channel: channel, subscriber: subscriber)
      : OptMessage.getOptOutMessage(channel: channel, subscriber: subscriber)

    return OptRequest(verificationProof: verificationProof, message: message)
  }
}
