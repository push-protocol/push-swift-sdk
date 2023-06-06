# restapi
This package gives access to Push Protocol (Push Nodes) APIs. Visit [Developer Docs](https://docs.push.org/developers) or [Push.org](https://push.org) to learn more.

## Channels

### Get Channel
```swift
let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
let res:PushChannel? = try await PushChannel.getChannel(
    options: PushChannel.GetChannelOption(
        channel: channelAddress, env: .STAGING
    ))
```
<details>
  <summary><b>PushChannel defination</b></summary>

```swift
public struct PushChannel{
  public let id: Int
  public let channel: String
  public let ipfshash: String
  public let name: String
  public let info: String
  public let url: String
  public let icon: String
  public let processed: Int
  public let attempts: Int
  public let alias_address: String
  public let alias_verification_event: String?
  public let is_alias_verified: Int
  public let alias_blockchain_id: String
  public let activation_status: Int
  public let verified_status: Int
  public let timestamp: String
  public let blocked: Int
  public let counter: Int?
  public let subgraph_details: String?
  public let subgraph_attempts: Int
}
```
</details>

---

### Get Channels List
```swift
let channels:PushChannel.Channels = try await PushChannel.getChannels(
    option: PushChannel.GetChannelsOptions(page: 1, limit: 10, env:.STAGING))
```

<details>
  <summary><b>PushChannel.Channels defination</b></summary>

```swift
public struct Channels{
    public let channels:[PushChannel] 
    public let itemcount:Int
}
```
</details>

---

### Search Channel
```swift
let query = "rayan channel" // or channel address 
let channels:PushChannel.Channels = try await PushChannel.search(
    option: PushChannel.SearchsOptions(query: query, page: 1, limit: 10, env: .STAGING))
```
<details>
  <summary><b>PushChannel.Channels defination</b></summary>

```swift
public struct Channels{
    public let channels:[PushChannel] 
    public let itemcount:Int
}
```
</details>

---

### Subscribe to a channel
```swift
let channelAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"

// returns boolean value based on request success
let result:Bool = try await PushChannel.subscribe(
    option: PushChannel.SubscribeOption(
        signer: Signer, 
        channelAddress: channelAddress, 
        env: .STAGING))
```

<details>
  <summary><b>Signer defination</b></summary>

Here `Signer` implements to the protocol `TypedSinger`
```swift
public protocol TypedSinger {
  func getEip712Signature(message: String)
    async throws -> String
  func getAddress() async throws -> String
}
```

`message` string is message to sign containing type information, a domain separator, and data complying with WalletConnect `eth_signTypedData` rpc message format.

for opt in `message` following string will be passed:
```json
{
  "types":{
    "Subscribe":[
      {
        "name":"channel",
        "type":"address"
      },
      {
        "name":"subscriber",
        "type":"address"
      },
      {
        "name":"action",
        "type":"string"
      }
    ],
    "EIP712Domain":[
      {
        "name":"name",
        "type":"string"
      },
      {
        "name":"chainId",
        "type":"uint256"
      },
      {
        "name":"verifyingContract",
        "type":"address"
      }
    ]
  },
  "primaryType":"Subscribe",
  "domain":{
    "name":"EPNS COMM V1",
    "chainId":5,
    "verifyingContract":"0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa"
  },
  "message":{
    "channel":"Channel Address",
    "subscriber":"Subscriber Address",
    "action":"Subscribe"
  }
}
```
</details>

---

### Unsubscribe to a channel
```swift
let channelAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"

// returns boolean value based on request success
let result:Bool = try await PushChannel.unsubscribe(
    option: PushChannel.SubscribeOption(
        signer: Signer, 
        channelAddress: channelAddress, 
        env: .STAGING))
```

<details>
<summary><b>Signer defination</b></summary>
Here `Signer` implements to the protocol `TypedSinger`
```swift
public protocol TypedSinger {
  func getEip712Signature(message: String)
    async throws -> String
  func getAddress() async throws -> String
}
```

`message` string is message to sign containing type information, a domain separator, and data complying with WalletConnect `eth_signTypedData` rpc message format.

for opt out `message` following string will be passed:
```json
{
  "types":{
    "Unsubscribe":[
      {
        "name":"channel",
        "type":"address"
      },
      {
        "name":"unsubscriber",
        "type":"address"
      },
      {
        "name":"action",
        "type":"string"
      }
    ],
    "EIP712Domain":[
      {
        "name":"name",
        "type":"string"
      },
      {
        "name":"chainId",
        "type":"uint256"
      },
      {
        "name":"verifyingContract",
        "type":"address"
      }
    ]
  },
  "primaryType":"Unsubscribe",
  "domain":{
    "name":"EPNS COMM V1",
    "chainId":5,
    "verifyingContract":"0xb3971BCef2D791bc4027BbfedFb47319A4AAaaAa"
  },
  "message":{
    "channel":"Channel Address",
    "unsubscriber":"Subscriber Address",
    "action":"Unsubscribe"
  }
}
```
</details>

---


### Get Subscribers
```swift
let subscribers:PushChannel.ChannelSubscribers = try await PushChannel.getSubscribers(
    option: PushChannel.GetChannelSubscribersOptions(
        channel: channelAddress, 
        page: 1, limit: 10, env: .STAGING))
```
<details>
  <summary><b>PushChannel.Channels defination</b></summary>

```swift
public struct ChannelSubscribers{
    public let itemcount: Int
    public let subscribers: [String] // eth address
}
```
</details>

---

### Check if user Subscribed to a channel
```swift
let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"

// returns true if user is subscribed
let isOptIn:Bool = try await PushChannel.getIsSubscribed(
      userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)
```