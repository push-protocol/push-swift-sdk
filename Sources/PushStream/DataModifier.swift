import Foundation

public class DataModifier {
    public    static func convertToProposedNameForSpace(_ currentEventName: String) -> String {
        switch currentEventName {
        case "create":
            return ProposedEventNames.CreateSpace.rawValue
        case "update":
            return ProposedEventNames.UpdateSpace.rawValue
        case "request":
            return ProposedEventNames.SpaceRequest.rawValue
        case "accept":
            return ProposedEventNames.SpaceAccept.rawValue
        case "reject":
            return ProposedEventNames.SpaceReject.rawValue
        case "leaveSpace":
            return ProposedEventNames.LeaveSpace.rawValue
        case "joinSpace":
            return ProposedEventNames.JoinSpace.rawValue
        case "remove":
            return ProposedEventNames.SpaceRemove.rawValue
        case "start":
            return ProposedEventNames.StartSpace.rawValue
        case "stop":
            return ProposedEventNames.StopSpace.rawValue
        default:
            fatalError("Unknown current event name: \(currentEventName)")
        }
    }

    public    static func handleChatGroupEvent(data: [String: Any], includeRaw: Bool = false) -> [String: Any] {
        switch data["eventType"] as? String {
        case "create":
            return mapToCreateGroupEvent(data: data, includeRaw: includeRaw)
        case "update":
            return mapToUpdateGroupEvent(data: data, includeRaw: includeRaw)
        case GroupEventType.JoinGroup.rawValue:
            return mapToJoinGroupEvent(data: data, includeRaw: includeRaw)
        case GroupEventType.LeaveGroup.rawValue:
            return mapToLeaveGroupEvent(data: data, includeRaw: includeRaw)
        case MessageEventType.Request.rawValue:
            return mapToRequestEvent(data: data, includeRaw: includeRaw)
        case GroupEventType.Remove.rawValue:
            return mapToRemoveEvent(data: data, includeRaw: includeRaw)
        default:
            print("Unknown eventType: \(data["eventType"] ?? "")")
            return data
        }
    }
    
    public   static func mapToRemoveEvent(data: [String: Any], includeRaw: Bool) -> [String: Any] {
        var eventData: [String: Any] = [
            "origin": data["messageOrigin"] as Any,
            "timestamp": data["timestamp"] as Any,
            "chatId": data["chatId"] as Any,
            "from": data["from"] as Any,
            "to": data["to"] as Any,
            "event": GroupEventType.Remove.rawValue
        ]

        if includeRaw {
            eventData["raw"] = ["verificationProof": data["verificationProof"] as Any]
        }

        return eventData
    }

    
    public   static func mapToRequestEvent(data: [String: Any], includeRaw: Bool) -> [String: Any] {
        var eventData: [String: Any] = [
            "origin": data["messageOrigin"] as Any,
            "timestamp": data["timestamp"] as Any,
            "chatId": data["chatId"] as Any,
            "from": data["from"] as Any,
            "to": data["to"] as Any,
            "event": MessageEventType.Request.rawValue,
            "meta": [
                "group": data["isGroup"] as? Bool ?? false
            ]
        ]

        if includeRaw {
            eventData["raw"] = ["verificationProof": data["verificationProof"] as Any]
        }

        return eventData
    }

    
    public   static func mapToLeaveGroupEvent(data: [String: Any], includeRaw: Bool) -> [String: Any] {
        var baseEventData: [String: Any] = [
            "origin": data["messageOrigin"] as Any,
            "timestamp": data["timestamp"] as Any,
            "chatId": data["chatId"] as Any,
            "from": data["from"] as Any,
            "to": data["to"] as Any,
            "event": GroupEventType.LeaveGroup.rawValue
        ]

        if includeRaw {
            baseEventData["raw"] = ["verificationProof": data["verificationProof"] as Any]
        }

        return baseEventData
    }
    
    public    static func mapToJoinGroupEvent(data: [String: Any], includeRaw: Bool) -> [String: Any] {
        var baseEventData: [String: Any] = [
            "origin": data["messageOrigin"] as Any,
            "timestamp": data["timestamp"] as Any,
            "chatId": data["chatId"] as Any,
            "from": data["from"] as Any,
            "to": data["to"] as Any,
            "event": GroupEventType.JoinGroup.rawValue
        ]

        if includeRaw {
            baseEventData["raw"] = ["verificationProof": data["verificationProof"] as Any]
        }

        return baseEventData
    }

    public   static func mapToCreateGroupEvent(data: [String: Any], includeRaw: Bool) -> [String: Any] {
        return mapToGroupEvent(eventType: GroupEventType.CreateGroup.rawValue, incomingData: data, includeRaw: includeRaw)
    } 
    
    public    static func mapToUpdateGroupEvent(data: [String: Any], includeRaw: Bool) -> [String: Any] {
        return mapToGroupEvent(eventType: GroupEventType.UpdateGroup.rawValue, incomingData: data, includeRaw: includeRaw)
    }

    public   static func mapToGroupEvent(eventType: String, incomingData: [String: Any], includeRaw: Bool) -> [String: Any] {
        let metaAndRaw = buildChatGroupEventMetaAndRaw(incomingData: incomingData, includeRaw: includeRaw)
        var groupEvent: [String: Any] = [
            "event": eventType,
            "origin": incomingData["messageOrigin"]!,
            "timestamp": incomingData["timestamp"]!,
            "chatId": incomingData["chatId"]!,
            "from": incomingData["from"]!,
            "meta": metaAndRaw["meta"]!,
        ]

        if includeRaw {
            groupEvent["raw"] = metaAndRaw["raw"]
        }

        return groupEvent
    }

    public  static func buildChatGroupEventMetaAndRaw(incomingData: [String: Any], includeRaw: Bool) -> [String: Any] {
        let meta: [String: Any] = [
            "name": incomingData["groupName"]!,
            "description": incomingData["groupDescription"]!,
            "image": incomingData["groupImage"]!,
            "owner": incomingData["groupCreator"]!,
            "private": !(incomingData["isPublic"] as? Bool ?? true),
            "rules": incomingData["rules"] ?? "",
        ]

        if includeRaw {
            let raw: [String: Any] = ["verificationProof": incomingData["verificationProof"] ?? ""]
            return ["meta": meta, "raw": raw]
        }

        return ["meta": meta]
    }

    public  static func convertToProposedName(_ currentEventName: String) -> String {
        switch currentEventName {
        case "message":
            return ProposedEventNames.Message.rawValue
        case "request":
            return ProposedEventNames.Request.rawValue
        case "accept":
            return ProposedEventNames.Accept.rawValue
        case "reject":
            return ProposedEventNames.Reject.rawValue
        case "leaveGroup":
            return ProposedEventNames.LeaveGroup.rawValue
        case "joinGroup":
            return ProposedEventNames.JoinGroup.rawValue
        case "createGroup":
            return ProposedEventNames.CreateGroup.rawValue
        case "updateGroup":
            return ProposedEventNames.UpdateGroup.rawValue
        case "remove":
            return ProposedEventNames.Remove.rawValue
        default:
            fatalError("Unknown current event name: \(currentEventName)")
        }
    }

    public  static func handleToField(_ data: inout [String: Any]) {
        switch data["event"] as? String {
        case ProposedEventNames.LeaveGroup.rawValue?,
             ProposedEventNames.JoinGroup.rawValue?:
            data["to"] = nil
        case ProposedEventNames.Accept.rawValue?,
             ProposedEventNames.Reject.rawValue?:
            if let group = data["meta"] as? [String: Any], group["group"] != nil {
                data["to"] = nil
            }
        default:
            break
        }
    }

   public static func handleChatEvent(_ data: [String: Any],_ includeRaw: Bool = false) -> [String: Any] {
        guard let eventTypeKey = data["eventType"] as? String ?? data["messageCategory"] as? String else {
            fatalError("Invalid eventType or messageCategory in data")
        }

        let eventTypeMap: [String: String] = [
            "Chat": MessageEventType.Message.rawValue,
            "Request": MessageEventType.Request.rawValue,
            "Approve": MessageEventType.Accept.rawValue,
            "Reject": MessageEventType.Reject.rawValue,
        ]

        guard let eventType = eventTypeMap[eventTypeKey] else {
            fatalError("Unknown eventType: \(eventTypeKey)")
        }

        return mapToMessageEvent(data: data, includeRaw: includeRaw, eventType: eventType)
    }

    public   static func mapToMessageEvent(data: [String: Any], includeRaw: Bool, eventType: String) -> [String: Any] {
        var eventType = eventType

        if let hasIntent = data["hasIntent"] as? Bool, hasIntent == false, eventType == MessageEventType.Message.rawValue {
            eventType = MessageEventType.Request.rawValue
        }

        var messageEvent: [String: Any?] = [
            "event": eventType,
            "origin": data["messageOrigin"] as? String? as Any,
            "timestamp": String(describing: data["timestamp"]!),
            "chatId": data["chatId"]!,
            "from": data["fromCAIP10"]!,
            "to": data["toCAIP10"] != nil ? [data["toCAIP10"]!] : [],
            "message": [
                "type": data["messageType"]!,
                "content": data["messageContent"]!,
            ],
            "meta": [
                "group": data["isGroup"] as? Bool ?? false,
            ],
            "reference": data["cid"]!,
        ]

        if includeRaw {
            let rawData: [String: Any] = [
                "fromCAIP10": data["fromCAIP10"]!,
                "toCAIP10": data["toCAIP10"] ?? "",
                "fromDID": data["fromDID"] ?? "",
                "toDID": data["toDID"] ?? "",
                "encType": data["encType"] ?? "",
                "encryptedSecret": data["encryptedSecret"] ?? "",
                "signature": data["signature"] ?? "",
                "sigType": data["sigType"] ?? "",
                "verificationProof": data["verificationProof"] ?? "",
                "previousReference": data["link"] ?? "",
            ]
            messageEvent["raw"] = rawData
        }

        return messageEvent
    }

//    static func mapToNotificationEvent(data: [String: Any], notificationEventType: String, origin: String, includeRaw: Bool) -> NotificationEvent {
//        let notificationType = NOTIFICATION_TYPE_MAP.keys.first { key in
//            NOTIFICATION_TYPE_MAP[key] == (data["payload"] as? [String: Any] ?? [:])["data"] as? String
//        } ?? "BROADCAST"
//
//        var recipients: [String] = []
//
//        if let payloadRecipients = data["payload"] as? [String: Any]? {
//            if let recipientsList = payloadRecipients?["recipients"] as? [String] {
//                recipients = recipientsList
//            } else if let recipientString = payloadRecipients?["recipients"] as? String {
//                recipients = [recipientString]
//            } else if let recipientsDict = payloadRecipients?["recipients"] as? [String: Any] {
//                recipients = Array(recipientsDict.keys)
//            }
//        }
//
//        let notificationEvent = NotificationEvent(
//            event: notificationEventType,
//            origin: origin,
//            timestamp: String(describing: data["epoch"]!),
//            from: data["sender"]! as! String,
//            to: recipients,
//            notifID: String(describing: data["payload_id"]!),
//            channel: NotificationChannel(
//                name: (data["payload"] as? [String: Any] ?? [:])["data"] as! String,
//                icon: (data["payload"] as? [String: Any] ?? [:])["icon"] as! String,
//                url: (data["payload"] as? [String: Any] ?? [:])["url"] as! String
//            ),
//            meta: NotificationMeta(
//                type: "NOTIFICATION.\(notificationType)"
//            ),
//            message: NotificationMessage(
//                notification: NotificationContent(
//                    title: (data["payload"] as? [String: Any] ?? [:])["notification"]?["title"] as! String,
//                    body: (data["payload"] as? [String: Any] ?? [:])["notification"]?["body"] as! String
//                ),
//                payload: NotificationPayload(
//                    title: (data["payload"] as? [String: Any] ?? [:])["data"]?["asub"] as! String
//                )
//            )
//        )
//
//        if includeRaw {
//            notificationEvent.raw = data["payload"] as? [String: Any] ?? [:]
//        }
//
//        return notificationEvent
//    }
}
