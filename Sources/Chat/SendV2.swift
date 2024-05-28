import Foundation

extension PushChat {
    struct ComputedOptions {
        public var messageType: MessageType
        public var messageObj: SendMessage
        public var account: String
        public var to: String
        public var pgpPrivateKey: String?
        public var env: ENV
    }

    static func computeOptions(_ options: SendOptions) throws -> ComputedOptions {
        let messageType = options.message?.type ?? options.messageType
        var messageObj: SendMessage? = options.message

        if messageObj == nil {
            if ![.Text, .Image, .File, .MediaEmbed].contains(messageType) {
                fatalError("Options.message is required")
            }
            // use messageContent for backwards compatibility
            messageObj = SendMessage(content: options.messageContent, type: messageType)
        }

        let to = options.to ?? options.receiverAddress

        if to.isEmpty {
            fatalError("Options.to is required")
        }

//        // Parse Reply Message
//        if messageType == MessageType.Reply {
//            if let replyContent = (messageObj as? SendMessage)?.replyContent {
//                (messageObj as? SendMessage)?.replyContent = NestedContent.fromNestedContent(replyContent)
//            } else {
//                throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Options.message is not properly defined for Reply"])
//            }
//        }

//        // Parse Composite Message
//        if messageType == MessageType.COMPOSITE.rawValue {
//            if let compositeContent = (messageObj as? SendMessage)?.compositeContent {
//                (messageObj as? SendMessage)?.compositeContent = compositeContent.map { nestedContent in
//                    NestedContent.fromNestedContent(nestedContent)
//                }
//            } else {
//                throw NSError(domain: "AppErrorDomain", code: -1, userInfo: [NSLocalizedDescriptionKey: "Options.message is not properly defined for Composite"])
//            }
//        }

        return ComputedOptions(
            messageType: messageType,
            messageObj: messageObj!,
            account: options.account,
            to: to,
            pgpPrivateKey: options.pgpPrivateKey,
            env: options.env
        )
    }

    static func validateSendOptions(options: ComputedOptions) throws {
        guard isValidETHAddress(address: options.account) else {
            fatalError("Invalid address \(options.account)")
        }

        guard options.pgpPrivateKey != nil else {
            fatalError("Please ensure that 'pgpPrivateKey' is properly defined.")
        }

        if options.messageObj.content.isEmpty {
            fatalError("Cannot send empty message")
        }
    }

    public struct SendOptionsV2 {
        public var message: SendMessage?

//        @available(*, deprecated, message: "Use message.content instead")
        public var messageContent = ""

//        @available(*, deprecated, message: "Use message.type instead")
        public var messageType: MessageType

//        @available(*, deprecated, message: "Use to instead")
        public var receiverAddress: String

        public var to: String?
        public var account: String
        public var pgpPrivateKey: String
        public var senderPgpPubicKey: String?
        public var receiverPgpPubicKey: String?
        public var processMessage: String?
        public var reference: String?
        public var env: ENV = .STAGING

        public enum Reactions: String {
            case THUMBSUP = "\u{1F44D}"
            case THUMBSDOWN = "\u{1F44E}"
            case HEART = "\u{2764}\u{FE0F}"
            case CLAP = "\u{1F44F}"
            case LAUGH = "\u{1F602}"
            case SAD = "\u{1F622}"
            case ANGRY = "\u{1F621}"
            case SURPRISE = "\u{1F632}"
            case FIRE = "\u{1F525}"
        }

        public init(
            message: SendMessage? = nil,
            messageContent: String, messageType: String, receiverAddress: String, account: String,
            pgpPrivateKey: String, refrence: String? = nil, env: ENV = .STAGING, to: String? = nil
        ) {
            self.messageContent = messageContent
            self.messageType = MessageType(rawValue: messageType)!
            self.receiverAddress = walletToPCAIP10(account: receiverAddress)
            self.account = walletToPCAIP10(account: account)
            self.pgpPrivateKey = pgpPrivateKey
            reference = refrence
            self.env = env
            self.to = to
            self.message = message
        }

        public func getMessageObjJSON() throws -> String {
            switch messageType {
            case .Text, .Image, .MediaEmbed:
                return try getJsonStringFromKV([
                    ("content", messageContent),
                ])
            case .Reaction:
                return try getJsonStringFromKV([
                    ("content", messageContent),
                    ("refrence", reference!),
                ])
            case .Reply:
                return """
                  {"content":{"messageType":"Text","messageObj":{"content":"\(messageContent)"}},"reference":"\(reference!)"}
                """.trimmingCharacters(in: .whitespaces)
            case .Video, .Audio, .File, .Meta, .Composite, .Receipt, .UserActivity, .Intent, .Payment:
                return try getJsonStringFromKV([
                    ("content", messageContent),
                    ("refrence", reference!),
                ])
            }
        }
    }

    public static func sendV2(chatOptions: SendOptions) async throws -> MessageV2 {
        let computedOptions = try computeOptions(chatOptions)

        try validateSendOptions(options: computedOptions)

        let isGroup = isGroupChatId(computedOptions.to)
        var groupInfo: PushGroupInfoDTO?

        if isGroup {
            groupInfo = try await getGroupInfoDTO(chatId: computedOptions.to, env: computedOptions.env)
        }

        let conversationHashResponse =
            try await ConversationHash(conversationId: computedOptions.to,
                                       account: computedOptions.account)
        let isIntent = !isGroup && conversationHashResponse == nil

        let senderAccount = try? await PushUser.get(account: computedOptions.account, env: computedOptions.env)

        if senderAccount == nil {
            fatalError("Cannot get sender account.")
        }

        var messageContent: String
        if computedOptions.messageType == .Reply ||
            computedOptions.messageType == .Composite {
            messageContent = "MessageType Not Supported by this sdk version. Plz upgrade !!!"
        } else {
            messageContent = computedOptions.messageObj.content
        }

        let payload =
            try await sendMessagePayloadCore(
                receiverAddress: computedOptions.to,
                senderAddress: computedOptions.account,
                senderPgpPrivateKey: computedOptions.pgpPrivateKey!,
                messageType: computedOptions.messageType,
                messageContent: messageContent,
                messageObj: computedOptions.messageObj,
                group: groupInfo,
                isGroup: isGroup,
                env: computedOptions.env)

//        if isIntent {
//            return try await sendIntentService(payload: sendMessagePayload, env: computedOptions.env)
//        } else {
//            return try await sendMessageService(payload: sendMessagePayload, env: computedOptions.env)
//        }

        let url = isIntent ? try PushEndpoint.sendChatIntent(env: computedOptions.env).url : try PushEndpoint.sendChatMessage(env: computedOptions.env).url
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(payload)
        print("url: \(url)")

        let body = try JSONEncoder().encode(payload)
        if let httpBodyString = String(data: body, encoding: .utf8) {
            print(httpBodyString)
        }

        let (data, res) = try await URLSession.shared.data(for: request)

        guard let httpResponse = res as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }

        do {
            return try JSONDecoder().decode(MessageV2.self, from: data)
        } catch {
            print("[Push SDK] - API \(error.localizedDescription)")
            throw error
        }
    }

    static func sendMessagePayloadCore(
        receiverAddress: String,
        senderAddress: String,
        senderPgpPrivateKey: String,
        messageType: MessageType,
        messageContent: String,
        messageObj: SendMessage,
        group: PushGroupInfoDTO?,
        isGroup: Bool,
        env: ENV
    ) async throws
        -> SendMessagePayloadV2 {
        var secretKey: String

        if isGroup, group != nil, group?.encryptedSecret != nil, group?.sessionKey != nil {
            secretKey = try Pgp.pgpDecrypt(cipherText: group!.encryptedSecret!, toPrivateKeyArmored: senderPgpPrivateKey)
        } else {
            secretKey = AESGCMHelper.generateRandomSecret(length: 15)
        }

        let encryptedMessageContentData = try await PayloadHelper.getEncryptedRequestCore(
            receiverAddress: receiverAddress,
            senderAddress: senderAddress,
            senderPgpPrivateKey: senderPgpPrivateKey,
            message: messageContent,
            isGroup: isGroup,
            group: group,
            env: env,
            secretKey: secretKey
        )

        let encryptedMessageContent = encryptedMessageContentData.message
        let deprecatedSignature = encryptedMessageContentData.signature

        let encryptedMessageObjData = try await PayloadHelper.getEncryptedRequestCore(
            receiverAddress: receiverAddress,
            senderAddress: senderAddress,
            senderPgpPrivateKey: senderPgpPrivateKey,
            message: messageObj.toJson(),
            isGroup: isGroup,
            group: group, env: env,
            secretKey: secretKey
        )
        let encryptedMessageObj = encryptedMessageObjData.message

        let encryptionType = encryptedMessageObjData.encryptionType

        let encryptedMessageObjSecret = encryptedMessageObjData.aesEncryptedSecret

        var body = SendMessagePayloadV2(
            fromDID: walletToPCAIP10(account: senderAddress),
            toDID: isGroup ? receiverAddress : walletToPCAIP10(account: receiverAddress),
            fromCAIP10: walletToPCAIP10(account: senderAddress),
            toCAIP10: isGroup ? receiverAddress : walletToPCAIP10(account: receiverAddress),
            messageContent: encryptedMessageContent,
            messageObj: encryptionType == "PlainText"
                ? messageObj
//            try messageObj.toJson()
                : encryptedMessageObj,
            messageType: messageType.rawValue,
            signature: deprecatedSignature,
            encType: encryptionType,
            encryptedSecret: encryptedMessageObjSecret,
            sigType: "pgpv3",
            sessionKey:
            (group != nil && group?.isPublic == false && encryptionType == "pgpv1:group")
                ? (group?.sessionKey ?? nil) : nil
        )

        let messageObjKey = "--body.messageObj--"
        var bodyToBehashed = try getJsonStringFromKV([
            ("fromDID", body.fromDID),
            ("toDID", body.fromDID), // TODO: correct this later
            ("fromCAIP10", body.fromCAIP10),
            ("toCAIP10", body.toCAIP10),
            ("messageObj", messageObjKey),
            ("messageType", body.messageType),
            ("encType", body.encType),
            ("sessionKey", body.sessionKey ?? "null"),
            ("encryptedSecret", body.encryptedSecret ?? "null"),
        ])
        bodyToBehashed = bodyToBehashed.replacingOccurrences(of: "\"\(messageObjKey)\"", with: try messageObj.toJson())

        let hash = generateSHA256Hash(msg: bodyToBehashed)

        let signature = try Pgp.sign(message: hash, privateKey: senderPgpPrivateKey)
        body.verificationProof = "pgpv3:\(signature)"

        return body
    }

    public static func removeVersionFromPublicKey(_ key: String) -> String {
        var lines = key.components(separatedBy: "\n")

        lines.removeAll { line in
            line.trimmingCharacters(in: .whitespacesAndNewlines).starts(with: "Version:")
        }

        return lines.joined(separator: "\n")
    }

    struct SendMessagePayloadV2: Encodable {
        var fromDID: String
        var toDID: String
        var fromCAIP10: String
        var toCAIP10: String
        var messageContent: String
        var messageObj: Any?
        var messageType: String
        var signature: String
        var encType: String
        var encryptedSecret: String?
        var sigType: String
        var verificationProof: String?
        var sessionKey: String?

        private enum CodingKeys: String, CodingKey {
            case fromDID, toDID, fromCAIP10, toCAIP10, messageContent, messageObj, messageType, signature,
                 encType,
                 encryptedSecret, sigType, verificationProof, sessionKey
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)

            try container.encode(fromDID, forKey: .fromDID)
            try container.encode(toDID, forKey: .toDID)
            try container.encode(fromCAIP10, forKey: .fromCAIP10)
            try container.encode(toCAIP10, forKey: .toCAIP10)
            try container.encode(messageContent, forKey: .messageContent)

            
            if let objString = messageObj as? String {
                try container.encode(objString, forKey: .messageObj)
            } else if let obj = messageObj as? SendMessage {
                try container.encode(obj, forKey: .messageObj)
            }

            try container.encode(messageType, forKey: .messageType)
            try container.encode(signature, forKey: .signature)
            try container.encode(encType, forKey: .encType)
            try container.encode(encryptedSecret, forKey: .encryptedSecret)

            try container.encode(sigType, forKey: .sigType)
            try container.encode(verificationProof, forKey: .verificationProof)
            try container.encode(sessionKey, forKey: .sessionKey)
        }
    }
    

    
}


public struct MessageV2: Codable {
    public var fromCAIP10: String
    public var toCAIP10: String
    public var fromDID: String
    public var toDID: String
    public var messageType: String
    public var messageContent: String
    public var messageObj: MessageObj? // Define a type that can represent both String and JSON
    public var signature: String
    public var sigType: String
    public var timestamp: Int?
    public var encType: String
    public var encryptedSecret: String?
    public var link: String?
    public var cid: String?
    public var sessionKey: String?
    
    // Implement a custom init(from:) initializer for decoding
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode properties from the container
        fromCAIP10 = try container.decode(String.self, forKey: .fromCAIP10)
        toCAIP10 = try container.decode(String.self, forKey: .toCAIP10)
        fromDID = try container.decode(String.self, forKey: .fromDID)
        toDID = try container.decode(String.self, forKey: .toDID)
        messageType = try container.decode(String.self, forKey: .messageType)
        messageContent = try container.decode(String.self, forKey: .messageContent)
        signature = try container.decode(String.self, forKey: .signature)
        sigType = try container.decode(String.self, forKey: .sigType)
        timestamp = try container.decodeIfPresent(Int.self, forKey: .timestamp)
        encType = try container.decode(String.self, forKey: .encType)
        encryptedSecret = try container.decodeIfPresent(String.self, forKey: .encryptedSecret)
        link = try container.decodeIfPresent(String.self, forKey: .link)
        cid = try container.decodeIfPresent(String.self, forKey: .cid)
        sessionKey = try container.decodeIfPresent(String.self, forKey: .sessionKey)
        
        do {
            self.messageObj  = try container.decodeIfPresent( MessageObj.self, forKey: .messageObj);
        }catch{
            do {
                let stringValue = try container.decodeIfPresent(String?.self, forKey: .messageObj)
                
                self.messageObj = MessageObj(content: stringValue ?? nil)
            } catch{
                self.messageObj = nil
            }
        }
    }
}


public struct MessageObj: Codable {
    let content: String?
}
