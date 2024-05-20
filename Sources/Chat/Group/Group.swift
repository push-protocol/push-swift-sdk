public enum GroupChatError: Error {
    case ONE_OF_ACCOUNT_OR_SIGNER_REQUIRED
    case INVALID_ETH_ADDRESS
    case CHAT_ID_NOT_FOUND
    case RUNTIME_ERROR(String)
}

extension PushChat {
   public struct GroupMemberPublicKey: Codable {
        let did: String
        let publicKey: String
    }

    public struct GetMemberPublicKeysResponse: Codable {
        let members: [GroupMemberPublicKey]
    }
    
    public struct GetMembersResponse: Codable {
        let members: [ChatMemberProfile]
    }

    public struct ChatMemberProfile: Codable {
        let address: String
        let intent: Bool
        let role: String
        let userInfo: UserData?

        init(address: String, intent: Bool, role: String, userInfo: UserData?) {
            self.address = address
            self.intent = intent
            self.role = role
            self.userInfo = userInfo
        }
    }

    public struct UserData: Codable {
        let msgSent: Int
        let maxMsgPersisted: Int
        let did: String
        let wallets: String
        let profile: UserProfile
        let encryptedPrivateKey: String?
        let publicKey: String?
        let verificationProof: String?
        let origin: String?
    }

    public struct UserProfile: Codable {
        let verificationProof: String?
        let profileVerificationProof: String?
        let picture: String
        let name: String?
        let desc: String?
        let blockedUsersList: [String]?
    }

    public struct GroupMemberStatus: Codable {
        let isMember: Bool
        let isPending: Bool
        let isAdmin: Bool

        init(isMember: Bool, isPending: Bool, isAdmin: Bool) {
            self.isMember = isMember
            self.isPending = isPending
            self.isAdmin = isAdmin
        }
    }

    public struct ChatMemberCounts: Codable {
        let totalMembersCount: TotalMembersCount
    }

    public struct TotalMembersCount: Codable {
        let overallCount: Int
        let adminsCount: Int
        let membersCount: Int
        let pendingCount: Int
        let approvedCount: Int
        let roles: MemberRoles
    }

    public struct MemberRoles: Codable {
        let admin: RoleCounts
        let member: RoleCounts
        
        enum CodingKeys: String, CodingKey {
               case admin = "ADMIN"
               case member = "MEMBER"
           }
    }

    public struct RoleCounts: Codable {
        let total: Int
        let pending: Int
    }



    public struct GroupAccess: Codable {
        public var entry: Bool?
        public var chat: Bool?
        public var rules: [String: String]?

        public init(entry: Bool, chat: Bool, rules: [String: String]?) {
            self.entry = entry
            self.chat = chat
            self.rules = rules
        }
    }

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

            public init(wallet: String, isAdmin: Bool, image: String, publicKey: String) {
                self.wallet = wallet
                self.isAdmin = isAdmin
                self.image = image
                self.publicKey = publicKey
            }
        }
    }

    public struct PushGroupInfoDTO: Codable {
        public var groupName: String
        public var groupDescription: String
        public var groupImage: String?
        public var isPublic: Bool
        public var groupCreator: String
        public var chatId: String
        public var groupType: String?
        public var meta: String?
        public var sessionKey: String?
        public var encryptedSecret: String?
    }
}
