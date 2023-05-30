import Foundation

extension Chats {
  struct ChatSendOptions {
    let messageContent = ""
    let messageType = "Text"
    let receiverAddress: String
    let account: String
    let signer: String
    let pgpPrivateKey: String
    let env: ENV = .STAGING
  }

  struct SendIntentAPIOptions{

  }

  static func send(chatOptions: ChatSendOptions) async throws {
    let senderAddress = walletToPCAIP10(account: chatOptions.account)
    let receiverAddress = walletToPCAIP10(account: chatOptions.receiverAddress)

    let isConversationFirst =
      try await ConversationHash(conversationId: receiverAddress, account: senderAddress) != nil

    if isConversationFirst {
      // send chat intent
      let url = try PushEndpoint.sendChatIntent(env: chatOptions.env).url

      var request = URLRequest(url: url)
      request.httpMethod = "POST"
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    //   request.httpBody = try JSONEncoder().encode(updatedData)
    //   let (data, res) = try await URLSession.shared.data(for: request)


    } else {
      // send regular message
    }
  }
}
