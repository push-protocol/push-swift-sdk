import Foundation
import SocketIO

public class PushStream: NSObject {
    public var account: String
    public var listen: [STREAM]
    private var decryptedPgpPvtKey: String
    private var env: ENV
    private var options: PushStreamInitializeOptions
    private var raw: Bool

    public var chat: Chat
    public var pushChatSocket: SocketIOClient
    private var pushChatSocketManager: SocketManager

    private var eventListeners = [String: [(Any) -> Void]]()

    var isChatSocketConnected = false

    init(account: String, listen: [STREAM], decryptedPgpPvtKey: String, env: ENV, options: PushStreamInitializeOptions) async throws {
        self.account = account
        self.listen = listen
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.env = env
        self.options = options
        raw = options.raw

        chat = Chat(account: account, decryptedPgpPvtKey: decryptedPgpPvtKey, env: env)

        let manager = try SocketClient.createSocketConnection(
            SocketInputOptions(
                user: walletToPCAIP10(account: account),
                env: env,
                socketType: .chat,
                socketOptions: SocketOptions(
                    autoConnect: options.connection.auto,
                    reconnectionAttempts: options.connection.retries
                )
            )
        )

        pushChatSocketManager = manager
        pushChatSocket = pushChatSocketManager.defaultSocket

        super.init()

        try await addSocketListeners()
    }

    public static func initialize(
        account: String,
        listen: [STREAM],
        decryptedPgpPvtKey: String,
        options: PushStreamInitializeOptions?,
        env: ENV
    ) async throws -> PushStream {
        print("initialize: env: \(env)")
        if listen.isEmpty {
            fatalError("The listen property must have at least one STREAM type.")
        }
        let settings = options ?? PushStreamInitializeOptions()
        let accountToUse = settings.overrideAccount ?? account

        return try await PushStream(
            account: accountToUse,
            listen: listen,
            decryptedPgpPvtKey: decryptedPgpPvtKey,
            env: env,
            options: settings
        )
    }
}

extension PushStream {
    func addSocketListeners() async throws {
        pushChatSocket.on(clientEvent: .connect) { [self] _, _ in
            self.checkAndEmitConnectEvent()
        }

        pushChatSocket.on(clientEvent: .error) { [self] data, _ in
            emit(STREAM.DISCONNECT.rawValue, data: "connection returned error: \(data)")
        }

        pushChatSocket.on(clientEvent: .disconnect, callback: { [self] _, _ in
            self.handleSocketDisconnection("chat")

        })

        pushChatSocket.on(EVENTS.chatGroups.rawValue, callback: { d, _ in
            
            print("EVENTS.chatGroups: data \(d.first)")
            let data = d.first as! [String: Any]
            print("EVENTS.chatGroups == data: \(data)")
            var modifiedData = DataModifier.handleChatGroupEvent(
                data: data,
                includeRaw: self.raw
            )

            modifiedData["event"] = DataModifier.convertToProposedName(modifiedData["event"] as! String)

            DataModifier.handleToField(&modifiedData)

            if self.shouldEmitChat(data["chatId"] as! String) {
                if data["eventType"] as! String == GroupEventType.JoinGroup.rawValue ||
                    data["eventType"] as! String == GroupEventType.LeaveGroup.rawValue ||
                    data["eventType"] as! String == MessageEventType.Request.rawValue ||
                    data["eventType"] as! String == GroupEventType.Remove.rawValue {
                    if self.shouldEmit(.CHAT) {
                        self.emit(STREAM.CHAT.rawValue, data: modifiedData)
                    }
                } else {
                    if self.shouldEmit(.CHAT_OPS) {
                        self.emit(STREAM.CHAT_OPS.rawValue, data: modifiedData)
                    }
                }
            }

        })
        
//        pushChatSocket.onAny({ event in
//            print(" pushChatSocket.onAny: event \(event)")
//            print(" pushChatSocket.onAny: event.event \(event.event)")
//            print(" pushChatSocket.onAny: event.items \(event.items)")
//            
//        })

//        print("EVENTS.chatReceivedMessage.rawValue \(EVENTS.chatReceivedMessage.rawValue)")
        pushChatSocket.on(EVENTS.chatReceivedMessage.rawValue, callback: { [self] d, _ in
            
            print("EVENTS.chatReceivedMessage == data: \(d.first)")
            Task {
                do {
                    var data = d.first as! [String: Any]
                    if data["messageCategory"] as! String == "Chat" ||
                        data["messageCategory"] as! String == "Request" {
                        let chat = try await chat.decrypt(
                            messagePayloads: [Message(dictionary: data)]
                        )

                        data = [
                            "messageCategory": data["messageCategory"] as! String,
                            "chatId": data["chatId"] as! String,
                        ]

                        data.merge(chat[0].toDictionary(), uniquingKeysWith: { _, new in new })
                    }

                    var modifiedData = DataModifier.handleChatEvent(data, raw) as [String: Any]
                    modifiedData["event"] = DataModifier.convertToProposedName(modifiedData["event"] as! String)
                    DataModifier.handleToField(&modifiedData)
                    if shouldEmitChat(data["chatId"] as! String) {
                        if shouldEmit(.CHAT) {
                            self.emit(STREAM.CHAT.rawValue, data: modifiedData)
                        }
                    }
                } catch {
                    fatalError("Error handling CHAT_RECEIVED_MESSAGE event: \(error)\tData: \(d.first as! [String: Any])")
                }
            }
        })
    }
}

extension PushStream {
    func checkAndEmitConnectEvent() {
        emit(STREAM.CONNECT.rawValue, data: "Connected Successfully")
        print("Emitted STREAM.CONNECT")
    }

    func handleSocketDisconnection(_ socketType: String) {
        if socketType == "chat" {
            emit(STREAM.DISCONNECT.rawValue, data: "Disonnected Successfully")
            print("Emitted STREAM.DISCONNECT")
        }
    }

    func shouldEmitChat(_ dataChatId: String) -> Bool {
        if let filter = options.filter,
           let chats = filter.chats,
           !chats.isEmpty,
           chats.contains("*") {
            return true
        }

        guard let filter = options.filter,
              let chats = filter.chats else {
            return false
        }

        return chats.contains(dataChatId)
    }

    func shouldEmit(_ eventType: STREAM) -> Bool {
        if listen.isEmpty {
            return false
        }

        return listen.contains(eventType)
    }

    public func on(_ event: String, listener: @escaping (Any) -> Void) {
        if eventListeners[event] == nil {
            eventListeners[event] = []
        }
        eventListeners[event]?.append(listener)
    }

    func emit(_ event: String, data: Any) {
        if let listeners = eventListeners[event] {
            for listener in listeners {
                listener(data)
            }
        }
    }
}

extension PushStream {
    public func connected() -> Bool {
        return pushChatSocket.status == .connected
    }

    public func disconnect() {
        pushChatSocket.disconnect()
    }

    public func connect() async throws {
        if pushChatSocket.status != .connected {
            pushChatSocket.connect(
                timeoutAfter: 15,
                withHandler: {
                    print("*** Failed to connect")
                })

        } else {
            // If pushChatSocket is already connected
            print("Push chat socket already connected")
        }
    }
}
