import Foundation

public struct PushStreamInitializeOptions {
    var filter: PushStreamFilter?
    var connection: PushStreamConnection
    var raw: Bool
    var env: ENV
    var overrideAccount: String?

  public  init(filter: PushStreamFilter? = nil,
         connection: PushStreamConnection? = nil,
         raw: Bool = false,
         env: ENV = .PROD,
         overrideAccount: String? = nil) {
        self.filter = filter
        self.connection = connection ?? PushStreamConnection()
        self.raw = raw
        self.env = env
        self.overrideAccount = overrideAccount
    }

    static func `default`() -> PushStreamInitializeOptions {
        return PushStreamInitializeOptions(connection: PushStreamConnection())
    }
}

public struct PushStreamFilter {
    var channels: [String]?
    var chats: [String]?
    var space: [String]?
    var video: [String]?
    
   public init(channels: [String]? = nil, chats: [String]? = nil, space: [String]? = nil, video: [String]? = nil) {
        self.channels = channels
        self.chats = chats
        self.space = space
        self.video = video
    }
}

public struct PushStreamConnection {
    var auto: Bool
    var retries: Int

    public  init(auto: Bool = true, retries: Int = 3) {
        self.auto = auto
        self.retries = retries
    }
}

public enum STREAM: String {
    case PROFILE = "STREAM.PROFILE"
    case ENCRYPTION = "STREAM.ENCRYPTION"
    case NOTIF = "STREAM.NOTIF"
    case NOTIF_OPS = "STREAM.NOTIF_OPS"
    case CHAT = "STREAM.CHAT"
    case CHAT_OPS = "STREAM.CHAT_OPS"
    case SPACE = "STREAM.SPACE"
    case SPACE_OPS = "STREAM.SPACE_OPS"
    case VIDEO = "STREAM.VIDEO"
    case CONNECT = "STREAM.CONNECT"
    case DISCONNECT = "STREAM.DISCONNECT"
}

public enum NotificationEventType: String {
    case INBOX = "notification.inbox"
    case SPAM = "notification.spam"
}

public enum MessageOrigin: String {
    case Other = "other"
    case Self_ = "self"
}

public enum MessageEventType: String {
    case Message = "message"
    case Request = "request"
    case Accept = "accept"
    case Reject = "reject"
}

public enum GroupEventType: String {
    case CreateGroup = "createGroup"
    case UpdateGroup = "updateGroup"
    case JoinGroup = "joinGroup"
    case LeaveGroup = "leaveGroup"
    case Remove = "remove"
    case RoleChange = "roleChange"
}

public enum SpaceEventType: String {
    case CreateSpace = "createSpace"
    case UpdateSpace = "updateSpace"
    case Join = "joinSpace"
    case Leave = "leaveSpace"
    case Remove = "remove"
    case Stop = "stop"
    case Start = "start"
}

public enum VideoEventType: String {
    case REQUEST = "video.request"
    case APPROVE = "video.approve"
    case DENY = "video.deny"
    case CONNECT = "video.connect"
    case DISCONNECT = "video.disconnect"
    // retry events
    case RETRY_REQUEST = "video.retry.request"
    case RETRY_APPROVE = "video.retry.approve"
}

public enum ProposedEventNames: String {
    case Message = "chat.message"
    case Request = "chat.request"
    case Accept = "chat.accept"
    case Reject = "chat.reject"
    case LeaveGroup = "chat.group.participant.leave"
    case JoinGroup = "chat.group.participant.join"
    case CreateGroup = "chat.group.create"
    case UpdateGroup = "chat.group.update"
    case Remove = "chat.group.participant.remove"
    case RoleChange = "chat.group.participant.role"

    case CreateSpace = "space.create"
    case UpdateSpace = "space.update"
    case SpaceRequest = "space.request"
    case SpaceAccept = "space.accept"
    case SpaceReject = "space.reject"
    case LeaveSpace = "space.participant.leave"
    case JoinSpace = "space.participant.join"
    case SpaceRemove = "space.participant.remove"
    case StartSpace = "space.start"
    case StopSpace = "space.stop"
}

public struct NotificationChannel {
    let name: String
    let icon: String
    let url: String
    
    init(name: String, icon: String, url: String) {
        self.name = name
        self.icon = icon
        self.url = url
    }
}
