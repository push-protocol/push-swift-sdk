import Foundation
import SocketIO

public class PushStream: EventEmitter {
    public var account: String
    public var listen: [STREAM]
    private var decryptedPgpPvtKey: String
    private var env: ENV
    private var options: PushStreamInitializeOptions

    public var chat: Chat
    public var pushChatSocket: SocketIOClient?
    public var pushNotificationSocket: SocketIOClient?

    init(account: String, listen: [STREAM], decryptedPgpPvtKey: String, env: ENV, options: PushStreamInitializeOptions) {
        self.account = account
        self.listen = listen
        self.decryptedPgpPvtKey = decryptedPgpPvtKey
        self.env = env
        self.options = options

        chat = Chat(account: account, decryptedPgpPvtKey: decryptedPgpPvtKey, env: env)
    }

  public  static func initialize(
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

        return PushStream(
            account: accountToUse,
            listen: listen,
            decryptedPgpPvtKey: decryptedPgpPvtKey,
            env: env,
            options: settings
        )
    }

    public func connect() async throws {
        emit("log", data: "is connecting..")
        let shouldInitializeChatSocket = !listen.isEmpty ||
            listen.contains(STREAM.CHAT) ||
            listen.contains(STREAM.CHAT_OPS)

        let shouldInitializeNotifSocket = !listen.isEmpty ||
            listen.contains(STREAM.NOTIF) ||
            listen.contains(STREAM.NOTIF_OPS)

        var isChatSocketConnected = false
        var isNotifSocketConnected = false

        func checkAndEmitConnectEvent() {
            if ((shouldInitializeChatSocket && isChatSocketConnected) ||
                !shouldInitializeChatSocket) &&
                ((shouldInitializeNotifSocket && isNotifSocketConnected) ||
                    !shouldInitializeNotifSocket) {
                emit(STREAM.CONNECT.rawValue, data: "")
                print("Emitted STREAM.CONNECT")
            }
        }

        func handleSocketDisconnection(_ socketType: String) async {
            if socketType == "chat" {
                isChatSocketConnected = false
                if isNotifSocketConnected {
                    if let pushNotificationSocket = pushNotificationSocket,
                       pushNotificationSocket.status == .connected {
                        pushNotificationSocket.disconnect()
                    }
                } else {
                    // Emit STREAM.DISCONNECT only if the chat socket was already disconnected
                    emit(STREAM.DISCONNECT.rawValue, data: "")
                    print("Emitted STREAM.DISCONNECT")
                }
            } else if socketType == "notif" {
                isNotifSocketConnected = false
                if isChatSocketConnected {
                    if let pushChatSocket = pushChatSocket,
                       pushChatSocket.status == .connected {
                        pushChatSocket.disconnect()
                    }
                } else {
                    // Emit STREAM.DISCONNECT only if the notification socket was already disconnected
                    emit(STREAM.DISCONNECT.rawValue, data: "")
                    print("Emitted STREAM.DISCONNECT")
                }
            }
        }

        if shouldInitializeChatSocket {
            if pushChatSocket == nil {
                // If pushChatSocket does not exist, create a new socket connection
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
                
               pushChatSocket =  manager.defaultSocket;

                if pushChatSocket == nil {
                    fatalError("Push chat socket not connected")
                }
            } else if pushChatSocket!.status != .connected {
                // If pushChatSocket exists but is not connected, attempt to reconnect
                pushChatSocket!.connect()
            } else {
                // If pushChatSocket is already connected
                print("Push chat socket already connected")
            }
        }

        if shouldInitializeNotifSocket {
            if pushNotificationSocket == nil {
                //TODO initialize push niofitication socket
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
            } else if pushNotificationSocket!.status != .connected {
                // If pushNotificationSocket exists but is not connected, attempt to reconnect
                print("Attempting to reconnect push notification socket...")
                pushNotificationSocket!.connect()
            } else {
                // If pushNotificationSocket is already connected
                print("Push notification socket already connected")
            }
        }

        func shouldEmit(_ eventType: STREAM) -> Bool {
            if listen.isEmpty {
                return false
            }

            return listen.contains(eventType)
        }

        if let pushChatSocket = pushChatSocket {
            pushChatSocket.on(EVENTS.connect.rawValue) { _, _ in
                isChatSocketConnected = true
                checkAndEmitConnectEvent()
                print("Chat Socket Connected (id: \(pushChatSocket.sid)")
            }
//
//                pushChatSocket.on(EVENTS.DISCONNECT) { data in
//                    await handleSocketDisconnection("chat")
//                }
//
//                pushChatSocket.on(EVENTS.CHAT_GROUPS) { data in
//                    do {
//                        let modifiedData = try DataModifier.handleChatGroupEvent(
//                            data: data,
//                            includeRaw: _raw
//                        )
//
//                        modifiedData["event"] = DataModifier.convertToProposedName(modifiedData["event"])
//
//                        DataModifier.handleToField(modifiedData)
//
//                        if _shouldEmitChat(data["chatId"]) {
//                            if data["eventType"] == GroupEventType.joinGroup ||
//                               data["eventType"] == GroupEventType.leaveGroup ||
//                               data["eventType"] == MessageEventType.request ||
//                               data["eventType"] == GroupEventType.remove {
//                                if shouldEmit(.CHAT) {
//                                    emit(STREAM.CHAT.value, modifiedData)
//                                }
//                            } else {
//                                if shouldEmit(.CHAT_OPS) {
//                                    emit(STREAM.CHAT_OPS.value, modifiedData)
//                                }
//                            }
//                        }
//                    } catch {
//                        log("Error handling CHAT_GROUPS event: \(error)\tData: \(data)")
//                    }
//                }
//
//                pushChatSocket.on(EVENTS.CHAT_RECEIVED_MESSAGE) { data in
//                    do {
//                        if data["messageCategory"] == "Chat" ||
//                           data["messageCategory"] == "Request" {
//                            // Don't call this if read only mode?
//                            if _signer != nil {
//                                let chat = try chatInstance.decrypt(
//                                    messagePayloads: [Message.fromJson(data)]
//                                )
//                                data = [
//                                    "messageCategory": data["messageCategory"],
//                                    "chatId": data["chatId"],
//                                    ...chat[0].toJson()
//                                ]
//                            }
//                        }
//
//                        let modifiedData = DataModifier.handleChatEvent(data, _raw)
//                        modifiedData["event"] = DataModifier.convertToProposedName(modifiedData["event"])
//                        DataModifier.handleToField(modifiedData)
//                        if _shouldEmitChat(data["chatId"]) {
//                            if shouldEmit(.CHAT) {
//                                emit(STREAM.CHAT.value, modifiedData)
//                            }
//                        }
//                    } catch {
//                        log("Error handling CHAT_RECEIVED_MESSAGE event: \(error)\tData: \(data)")
//                    }
//                }
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
}
