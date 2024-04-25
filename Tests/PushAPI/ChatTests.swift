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
}

