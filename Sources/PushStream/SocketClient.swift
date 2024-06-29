import SocketIO
import Foundation

public enum SocketTypes : String {
    case notification = "notification"
    case chat = "chat"
}

public enum EVENTS: String {
    // Websocket
    case connect = "connect"
    case disconnect = "disconnect"

    // Notification
    case userFeeds = "userFeeds"
    case userSpamFeeds = "userSpamFeeds"

    // Chat
    case chatReceivedMessage = "CHATS"
    case chatGroups = "CHAT_GROUPS"

    // Spaces
    case spacesMessages = "SPACES_MESSAGES"
    case spaces = "SPACES"
}


public struct SocketClient{
    public enum SocketError: Error {
        case notificationSocketsNotSupported
    }
    static public func createSocketConnection(_ options: SocketInputOptions) throws -> SocketManager {
        let pushWSUrl = "https://\(ENV.getHost(withEnv: options.env))"
        
        var userAddressInCAIP:String;
        
        if options.socketType == .chat {
            userAddressInCAIP = walletToPCAIP10(account: options.user)
        }else{
            //TODO implement getCAIPAddress
            throw SocketError.notificationSocketsNotSupported
        }
        
        var query : [String:String] = [:]
        
        if options.socketType == .notification {
            query = ["address": userAddressInCAIP]
  
        }else{
            query = ["mode": "chat", "did": userAddressInCAIP]
        }
        
        print("query: \(query)")
        
        var config = [
            .log(true),
            .compress,
            .reconnects(options.socketOptions?.autoConnect == true),
            .connectParams(query),
            .forceWebsockets(true),
            .secure(true),
            .extraHeaders(["Sec-WebSocket-Extensions":"permessage-deflate"])
        ] as SocketIOClientConfiguration
        
        if options.socketOptions?.reconnectionDelay != nil{
            config.insert(.reconnectWait(options.socketOptions!.reconnectionDelay!))
        } 
        
        if options.socketOptions?.reconnectionDelayMax != nil{
            config.insert(.reconnectWaitMax(options.socketOptions!.reconnectionDelayMax!))
        }
        
        // Create a Socket.IO manager instance
        let socketManager = SocketManager(socketURL: URL(string: pushWSUrl)!, config: config)
        
        print("pushWSUrl: \(pushWSUrl)")
        print("socketManager: \(socketManager)")
        print("config: \(config)")
        
        return socketManager
    }
}


public struct SocketOptions {
    var autoConnect: Bool
    var reconnectionAttempts: Int
    var reconnectionDelayMax: Int?
    var reconnectionDelay: Int?
    
    public init(autoConnect: Bool = true,
         reconnectionAttempts: Int = 5, reconnectionDelayMax: Int? = nil, reconnectionDelay: Int? = nil) {
        self.autoConnect = autoConnect
        self.reconnectionAttempts = reconnectionAttempts
        self.reconnectionDelayMax = reconnectionDelayMax
        self.reconnectionDelay = reconnectionDelay
    }
}

public struct SocketInputOptions {
    var user: String
    var env: ENV
    var socketType: SocketType?
    var socketOptions: SocketOptions?
     
     
     public  init(user: String, env: ENV, socketType: SocketType? = nil, socketOptions: SocketOptions? = nil) {
         self.user = user
         self.env = env
         self.socketType = socketType
         self.socketOptions = socketOptions
     }
}

public enum SocketType: String {
    case notification = "notification"
    case chat = "chat"
}
