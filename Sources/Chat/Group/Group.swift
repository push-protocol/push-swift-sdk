public enum GroupChatError: Error {
    case ONE_OF_ACCOUNT_OR_SIGNER_REQUIRED
    case INVALID_ETH_ADDRESS
    case CHAT_ID_NOT_FOUND
    case RUNTIME_ERROR(String)
}

extension PushChat {
    public struct GroupMemberPublicKey: Codable {
        public let did: String
        public let publicKey: String
    }

    public struct GetMemberPublicKeysResponse: Codable {
        public let members: [GroupMemberPublicKey]
    }

    public struct GetMembersResponse: Codable {
        public let members: [ChatMemberProfile]
    }

    public struct ChatMemberProfile: Codable {
        public let address: String
        public let intent: Bool
        public let role: String
        public let userInfo: UserData?

        init(address: String, intent: Bool, role: String, userInfo: UserData?) {
            self.address = address
            self.intent = intent
            self.role = role
            self.userInfo = userInfo
        }
    }

    public struct UserData: Codable {
        public let msgSent: Int
        public let maxMsgPersisted: Int
        public let did: String
        public let wallets: String
        public let profile: UserProfile
        public let encryptedPrivateKey: String?
        public let publicKey: String?
        public let verificationProof: String?
        public let origin: String?
    }

    public struct UserProfile: Codable {
        public let verificationProof: String?
        public let profileVerificationProof: String?
        public let picture: String
        public let name: String?
        public let desc: String?
        public let blockedUsersList: [String]?
    }

    public struct GroupMemberStatus: Codable {
        public let isMember: Bool
        public let isPending: Bool
        public let isAdmin: Bool

        init(isMember: Bool, isPending: Bool, isAdmin: Bool) {
            self.isMember = isMember
            self.isPending = isPending
            self.isAdmin = isAdmin
        }
    }

    public struct ChatMemberCounts: Codable {
        public let totalMembersCount: TotalMembersCount
    }

    public struct TotalMembersCount: Codable {
        public let overallCount: Int
        public let adminsCount: Int
        public let membersCount: Int
        public let pendingCount: Int
        public let approvedCount: Int
        public let roles: MemberRoles
    }

    public struct MemberRoles: Codable {
        public let admin: RoleCounts
        public let member: RoleCounts

        enum CodingKeys: String, CodingKey {
            case admin = "ADMIN"
            case member = "MEMBER"
        }
    }

    public struct RoleCounts: Codable {
        public let total: Int
        public let pending: Int
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
