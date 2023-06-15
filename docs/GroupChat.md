# restapi
This package gives access to Push Protocol (Push Nodes) APIs. Visit [Developer Docs](https://docs.push.org/developers) or [Push.org](https://push.org) to learn more.

## Group Chat

---

### Create Group
```swift
let createGroupOptions = try PushChat.CreateGroupOptions(
  name: "Group Name",
  description: "Group Description",
  image:
    "data:image/png;base64,iVBORw0KGgo.....",
  members: ["0x78BDF89BB0fD820f2618662e42E26a7adc1Ba7b7", "0x1ceB36CDa8a87839aDD9dB9D5a9419AEa720c64A"], // Max 10
  isPublic: false, // Only in private group messages are encrypted
  creatorAddress: "GROUP_CREATOR_ETH_ADDRESS",
  creatorPgpPrivateKey: "PGP_PRIVATE_KEY",
  env: ENV.STAGING
)

let group:PushChat.PushGroup = try await PushChat.createGroup(options: createGroupOptions)
```
<details>
  <summary><b>PushGroup defination</b></summary>

```swift
public struct PushGroup{
    public var members: [Member]
    public var pendingMembers: [Member]
    public var contractAddressERC20: String?
    public var numberOfERC20: Int
    public var contractAddressNFT: String?
    public var numberOfNFTTokens: Int
    public var verificationProof: String
    public var groupImage: String
    public var groupName: String
    public var groupDescription: String
    public var isPublic: Bool
    public var groupCreator: String
    public var chatId: String
    public var scheduleAt: String?
    public var scheduleEnd: String?
    public var groupType: String
    public var status: String?
    public var eventType: String?

    public struct Member{
      public let wallet: String
      public let publicKey: String?
      public let isAdmin: Bool
      public let image: String?

      public init(wallet: String, isAdmin: Bool, image: String, publicKey: String) {
        self.wallet = wallet
        self.isAdmin = isAdmin
        self.image = image
        self.publicKey = publicKey
      }
    }
  }
```
</details>

---

### Get Group
```swift
let chatId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
 
let group:PushChat.PushGroup? = try await PushChat.getGroup(chatId: chatId, env: .STAGING)
```

> returns `nil` if group doesnot exist

<details>
  <summary><b>PushGroup defination</b></summary>

```swift
public struct PushGroup{
    public var members: [Member]
    public var pendingMembers: [Member]
    public var contractAddressERC20: String?
    public var numberOfERC20: Int
    public var contractAddressNFT: String?
    public var numberOfNFTTokens: Int
    public var verificationProof: String
    public var groupImage: String
    public var groupName: String
    public var groupDescription: String
    public var isPublic: Bool
    public var groupCreator: String
    public var chatId: String
    public var scheduleAt: String?
    public var scheduleEnd: String?
    public var groupType: String
    public var status: String?
    public var eventType: String?

    public struct Member{
      public let wallet: String
      public let publicKey: String?
      public let isAdmin: Bool
      public let image: String?

      public init(wallet: String, isAdmin: Bool, image: String, publicKey: String) {
        self.wallet = wallet
        self.isAdmin = isAdmin
        self.image = image
        self.publicKey = publicKey
      }
    }
  }
```
</details>

---

### Update Group
```swift
// get the group
let chatId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
var group = try await PushChat.getGroup(chatId: chatId, env: .STAGING)!

// update the group params
group.groupName = "New group name"
group.groupDescription = "New group description" 
group.groupImage = "New BASE64 Image"

let updatedGroup:PushGroup = try await PushChat.updateGroup(
    updatedGroup: group, 
    adminAddress: UserEthAddress, 
    adminPgpPrivateKey: UserPGPPrivateKey,
    env: .STAGING
)
```

<details>
  <summary><b>PushGroup defination</b></summary>

```swift
public struct PushGroup{
    public var members: [Member]
    public var pendingMembers: [Member]
    public var contractAddressERC20: String?
    public var numberOfERC20: Int
    public var contractAddressNFT: String?
    public var numberOfNFTTokens: Int
    public var verificationProof: String
    public var groupImage: String
    public var groupName: String
    public var groupDescription: String
    public var isPublic: Bool
    public var groupCreator: String
    public var chatId: String
    public var scheduleAt: String?
    public var scheduleEnd: String?
    public var groupType: String
    public var status: String?
    public var eventType: String?

    public struct Member{
      public let wallet: String
      public let publicKey: String?
      public let isAdmin: Bool
      public let image: String?

      public init(wallet: String, isAdmin: Bool, image: String, publicKey: String) {
        self.wallet = wallet
        self.isAdmin = isAdmin
        self.image = image
        self.publicKey = publicKey
      }
    }
  }
```
</details>

---

### Send Message To Group
Same as P2P chat. Instead of receiver address group chat id is required

```swift
let chatId = "8fe92fe913370a0bde2777dc543d0668de6c0bb9cee9f71d0d10da962d50f6c3"
let message = "Hello Group"

let msgRes:Message = try await PushChat.send(
    PushChat.SendOptions(
        messageContent: meessage,
        messageType: "Text",
        receiverAddress: chatId,
        account: UserEthAddress,
        pgpPrivateKey: UserPGPPrivateKey
    ))
```

<details>
  <summary><b>Message defination</b></summary>

```swift
public struct Message{
  public var fromCAIP10: String
  public var toCAIP10: String
  public var fromDID: String
  public var toDID: String
  public var messageType: String
  public var messageContent: String
  public var signature: String
  public var sigType: String
  public var timestamp: Int?
  public var encType: String
  public var encryptedSecret: String
  public var link: String?
}
```
</details>

---


### Accept to the Group Request
Same as P2P chat. Instead of request sender address group chat id is required
```swift
let chatId = "8fe92fe913370a0bde2777dc543d0668de6c0bb9cee9f71d0d10da962d50f6c3"

let response:String = try await PushChat.approve(
    PushChat.ApproveOptions(
        fromAddress: chatId, 
        toAddress: UserEthAddress, 
        privateKey: UserPgpPrivateKey, 
        env: .STAGING
    ))
```

