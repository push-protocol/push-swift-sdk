import Foundation
import SocketIO

public class PushStream: EventEmitter {
    public var account: String
    public var listen: [STREAM]
    private var decryptedPgpPvtKey: String
    private var env: ENV
    private var options: PushStreamInitializeOptions
    private var raw: Bool

    public var chat: Chat
    public var pushChatSocket: SocketIOClient?

    var isChatSocketConnected = false
//    public var pushNotificationSocket: SocketIOClient?

    init(account: String, listen: [STREAM], decryptedPgpPvtKey: String, env: ENV, options: PushStreamInitializeOptions) throws {
        self.account = account
        self.listen = listen
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.env = env
        self.options = options
        raw = options.raw

        chat = Chat(account: account, decryptedPgpPvtKey: decryptedPgpPvtKey, env: env)

        super.init()

        try initSocket()
    }

    func checkAndEmitConnectEvent() {
        print("checkAndEmitConnectEvent....")
        if isChatSocketConnected {
            emit(STREAM.CONNECT.rawValue, data: "")
            print("Emitted STREAM.CONNECT")
        }
    }

    func initSocket() throws {
        let shouldInitializeChatSocket = !listen.isEmpty ||
            listen.contains(STREAM.CHAT) ||
            listen.contains(STREAM.CHAT_OPS)

        if !shouldInitializeChatSocket {
            return
        }

        let manager = try SocketClient.createSocketConnection(
            SocketInputOptions(
                user: walletToPCAIP10(account: account),
                env: options.env,
                socketType: .chat,
                socketOptions: SocketOptions(
                    autoConnect: options.connection.auto,
                    reconnectionAttempts: options.connection.retries
                )
            )
        )

        self.pushChatSocket = manager.defaultSocket
        print("pushChatSocket is initialized...\(String(describing: pushChatSocket))")

        self.pushChatSocket?.on(clientEvent: .error) { data, _ in
            self.isChatSocketConnected = false
            print("connection returned error:\(data) ")
        }  
        
        self.pushChatSocket?.on(clientEvent: .connect) { data, _ in
            self.isChatSocketConnected = false
            print("connection returned connect:\(data) ")
        }
        //TODO remove this later
        self.pushChatSocket?.connect(timeoutAfter: 5, withHandler: {
            print("Error connecting")
        })
        
        if self.pushChatSocket == nil {
            fatalError("Push chat socket not connected")
        }
        
        return;

        if let pushChatSocket = self.pushChatSocket {
            pushChatSocket.on(clientEvent: .connect) { _, _ in
                print("clientEvent: .connect: called...")
                self.isChatSocketConnected = true
                Task {
                    
                    self.checkAndEmitConnectEvent()
                }
            }
            pushChatSocket.on(clientEvent: .error) { data, _ in
                self.isChatSocketConnected = false
                print("connection returned error:\(data) ")
            }

            pushChatSocket.on(clientEvent: .disconnect) { _, _ in
                Task {
                    await self.handleSocketDisconnection("chat")
                }
            }

            pushChatSocket.on(EVENTS.chatGroups.rawValue, callback: { d, _ in

                let data = d.first as! [String: Any]
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

            pushChatSocket.on(EVENTS.chatReceivedMessage.rawValue, callback: { [self] d, _ in
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
            
           

//
//                pushChatSocket.on(EVENTS.SPACES) { data in
//                    do {
//                        let modifiedData = DataModifier.handleSpaceEvent(
//                            data: data,
//                            includeRaw: _raw
//                        )
//                        modifiedData["event"] = DataModifier.convertToProposedNameForSpace(modifiedData["event"])
//
//                        DataModifier.handleToField(modifiedData)
//
//                        if _shouldEmitSpace(data["spaceId"]) {
//                            if data["eventType"] == SpaceEventType.join ||
//                               data["eventType"] == SpaceEventType.leave ||
//                               data["eventType"] == MessageEventType.request ||
//                               data["eventType"] == SpaceEventType.remove ||
//                               data["eventType"] == SpaceEventType.start ||
//                               data["eventType"] == SpaceEventType.stop {
//                                if shouldEmit(.SPACE) {
//                                    emit(STREAM.SPACE.value, modifiedData)
//                                }
//                            } else {
//                                if shouldEmit(.SPACE_OPS) {
//                                    emit(STREAM.SPACE_OPS.value, modifiedData)
//                                }
//                            }
//                        }
//                    } catch {
//                        log("Error handling SPACES event: \(error), Data: \(data)")
//                    }
//                }
//
//                pushChatSocket.on(EVENTS.SPACES_MESSAGES) { data in
//                    do {
//                        let modifiedData = DataModifier.handleSpaceEvent(
//                            data: data,
//                            includeRaw: _raw
//                        )
//                        modifiedData["event"] = DataModifier.convertToProposedNameForSpace(modifiedData["event"])
//
//                        DataModifier.handleToField(modifiedData)
//
//                        if _shouldEmitSpace(data["spaceId"]) {
//                            if shouldEmit(.SPACE) {
//                                emit(STREAM.SPACE.value, modifiedData)
//                            }
//                        }
//                    } catch {
//                        log("Error handling SPACES event: \(error), Data: \(data)")
//                    }
//                }
        }
    }

    func handleSocketDisconnection(_ socketType: String) async {
        print("handleSocketDisconnection: socketType: \(socketType)")
        print("Emitted STREAM.DISCONNECT")
        if socketType == "chat" {
            isChatSocketConnected = false
            // Emit STREAM.DISCONNECT only if the chat socket was already disconnected
            emit(STREAM.DISCONNECT.rawValue, data: "")
            print("Emitted STREAM.DISCONNECT")
        }
//        else if socketType == "notif" {
//                isNotifSocketConnected = false
//                if isChatSocketConnected {
//                    if let pushChatSocket = pushChatSocket,
//                       pushChatSocket.status == .connected {
//                        pushChatSocket.disconnect()
//                    }
//                } else {
//                    // Emit STREAM.DISCONNECT only if the notification socket was already disconnected
//                    emit(STREAM.DISCONNECT.rawValue, data: "")
//                    print("Emitted STREAM.DISCONNECT")
//                }
//            }
    }

    public static func initialize(
        account: String,
        listen: [STREAM],
        decryptedPgpPvtKey: String,
        options: PushStreamInitializeOptions?,
        env: ENV
    ) throws -> PushStream {
        if listen.isEmpty {
            fatalError("The listen property must have at least one STREAM type.")
        }
        let settings = options ?? PushStreamInitializeOptions()
        let accountToUse = settings.overrideAccount ?? account

        return try PushStream(
            account: accountToUse,
            listen: listen,
            decryptedPgpPvtKey: decryptedPgpPvtKey,
            env: env,
            options: settings
        )
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

    public func connected() -> Bool {
        print("pushChatSocket!.status: \(self.pushChatSocket!.status)")
//        (pushNotificationSocket != nil && pushNotificationSocket!.status == .connected) ||
        return self.pushChatSocket != nil && self.pushChatSocket!.status == .connected
    }

    public func disconnect() {
        if pushChatSocket != nil {
            pushChatSocket?.disconnect()
        }

//        if pushNotificationSocket != nil {
//            pushNotificationSocket?.disconnect()
//        }
    }

    public func connect() async throws {
//        let shouldInitializeNotifSocket = !listen.isEmpty ||
//            listen.contains(STREAM.NOTIF) ||
//            listen.contains(STREAM.NOTIF_OPS)

//        var isNotifSocketConnected = false

        if pushChatSocket == nil {
            // If pushChatSocket does not exist, create a new socket connection
            try initSocket()
            pushChatSocket!.connect()

        } else if pushChatSocket!.status != .connected {
            print("call..pushChatSocket!.connect()")
            // If pushChatSocket exists but is not connected, attempt to reconnect
//            pushChatSocket!.connect()
            pushChatSocket!.connect(
                timeoutAfter: 15,
                withHandler: {
                    print("*** Failed to connect")
                })

        } else {
            // If pushChatSocket is already connected
            print("Push chat socket already connected")
        }

//        if shouldInitializeNotifSocket {
//            if pushNotificationSocket == nil {
        // TODO: initialize push niofitication socket
        // If pushNotificationSocket does not exist, create a new socket connection
//                let manager = try SocketClient.createSocketConnection(
//                    SocketInputOptions(
//                        user: walletToPCAIP10(account: account),
//                        env: options.env,
//                        socketType: .notification,
//                        socketOptions: SocketOptions(
//                            autoConnect: options.connection.auto,
//                            reconnectionAttempts: options.connection.retries
//                        )
//                    )
//                )
//
//                pushNotificationSocket = manager.defaultSocket

//                if pushNotificationSocket == nil {
//                    fatalError("Push notification socket not connected")
//                }
//            } else if pushNotificationSocket!.status != .connected {
//                // If pushNotificationSocket exists but is not connected, attempt to reconnect
//                print("Attempting to reconnect push notification socket...")
//                pushNotificationSocket!.connect()
//            } else {
//                // If pushNotificationSocket is already connected
//                print("Push notification socket already connected")
//            }
//        }
    }
}
