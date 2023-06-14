public enum GroupChatError: Error {
  case ONE_OF_ACCOUNT_OR_SIGNER_REQUIRED
  case INVALID_ETH_ADDRESS
  case RUNTIME_ERROR(String)
}

extension PushChat {
  public struct PushGroup: Codable {
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

    public struct Member: Codable {
      public let wallet: String
      public let publicKey: String?
      public let isAdmin: Bool
      public let image: String?

      public init(wallet: String, isAdmin: Bool, image:String, publicKey:String) {
        self.wallet = wallet
        self.isAdmin = isAdmin
        self.image = image
        self.publicKey = publicKey
      }
    }
  }
}
