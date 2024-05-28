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
    
    func testSend() async throws{
        let alicePk = "a59c37c9b61b73f824972b901e0b4ae914750fd8de94c5dfebc4934ff1d12d3c" ///getRandomAccount()
        let bobPk = "0ab2b8f38a851c8e8782119fd1e202290b5c86736506525acde7b404260beba7"//getRandomAccount()
        
        print("alicePk: \(alicePk)")
        print("bobPk: \(bobPk)")
    

        // Initialize signers
        let aliceSigner = try SignerPrivateKey(privateKey: alicePk)
        let bobSigner = try SignerPrivateKey(privateKey: bobPk)

        // Store Address
        let aliceAddress = try await aliceSigner.getAddress()
        let bobAddress = try await bobSigner.getAddress()
        print("aliceAddress: \(aliceAddress)")
        print("bobAddress: \(bobAddress)")

        // Initialize PushAPI
        let userAlice = try await PushAPI
            .initializePush(
                signer: aliceSigner,
                options: PushAPI.PushAPIInitializeOptions(
                    env: .STAGING)
            )

        let userBob = try await PushAPI
            .initializePush(
                signer: bobSigner,
                options: PushAPI.PushAPIInitializeOptions(env: .STAGING)
            )
        
      let message =   try await userAlice.chat.send(
        target: "0x239DE7CCBDBa7aD73C12273Be49674bD2c9D5016",
        message: PushChat.SendMessage(content: "Food", type: .Text))
        
        print("Message: \(message)")
    }

}

