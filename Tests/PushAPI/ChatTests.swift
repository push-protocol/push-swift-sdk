import Push
import XCTest

class ChatTests: XCTestCase {
    
    func testChatLists() async throws {
        let userPk = getRandomAccount()
        let signer = try SignerPrivateKey(privateKey: userPk)

        let pushAPI = try await PushAPI
            .initializePush(
                signer: signer,
                options: PushAPI.PushAPIInitializeOptions()
            )
        
        let requests = try await pushAPI.chat.list(type: .REQUESTS)
        XCTAssertEqual(requests.count, 0)
        
        
        let chats = try await pushAPI.chat.list(type: .CHAT)
        XCTAssertEqual(chats.count, 0)
    }
    
    func testLatestChat() async throws {
        let userPk = getRandomAccount()
        let signer = try SignerPrivateKey(privateKey: userPk)

        let pushAPI = try await PushAPI
            .initializePush(
                signer: signer,
                options: PushAPI.PushAPIInitializeOptions()
            )
        
        let latest = try await pushAPI.chat.latest(target: "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6")
      
        print(latest?.messageContent ?? "No message")
    }

}

