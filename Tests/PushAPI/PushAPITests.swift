import Push
import XCTest

class PushAPITests: XCTestCase {
    func testInitialize() async throws {
        let userPk = getRandomAccount()
        let signer = try SignerPrivateKey(privateKey: userPk)
        let address = try await signer.getAddress()

        let pushAPI = try await PushAPI
            .initializePush(
                signer: signer,
                options: PushAPI.PushAPIInitializeOptions()
            )

        let user = try await pushAPI.profile.info()

        XCTAssertEqual(user?.did, "eip155:\(address)")
    }

    func testProfileUpdate() async throws {
        let userPk = getRandomAccount()
        let signer = try SignerPrivateKey(privateKey: userPk)

        let pushAPI = try await PushAPI
            .initializePush(
                signer: signer,
                options: PushAPI.PushAPIInitializeOptions()
            )

        let newName = "Push Swift"

        try await pushAPI.profile.update(name: newName, desc: "Push Swift Tester")

        let user = try await pushAPI.profile.info()

        XCTAssertEqual(user?.profile.name, newName)
    }

    func testPublicGroup() async throws {
        // Generate Private Keys
        let alicePk = getRandomAccount()
        let bobPk = getRandomAccount()
        let johnPk = getRandomAccount()
        let markPk = getRandomAccount()

        // Initialize signers
        let aliceSigner = try SignerPrivateKey(privateKey: alicePk)
        let bobSigner = try SignerPrivateKey(privateKey: bobPk)
        let johnSigner = try SignerPrivateKey(privateKey: johnPk)
        let markSigner = try SignerPrivateKey(privateKey: markPk)

        // Store Address
        let aliceAddress = try await aliceSigner.getAddress()
        let bobAddress = try await bobSigner.getAddress()
        let johnAddress = try await johnSigner.getAddress()
        let markAddress = try await johnSigner.getAddress()

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

        let userJohn = try await PushAPI
            .initializePush(
                signer: johnSigner,
                options: PushAPI.PushAPIInitializeOptions(env: .STAGING)
            )

        let userMark = try await PushAPI
            .initializePush(
                signer: markSigner,
                options: PushAPI.PushAPIInitializeOptions(env: .STAGING)
            )

        let newName = "Push Swift"
        let groupOptions = Group.GroupCreationOptions(
            description: "Push Swift Test",
            image: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O/OyBjzh3CD95BfqICMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMO0TAAD//2Anhf4QtqobAAAAAElFTkSuQmCC",
            members: [aliceAddress],
            admins: [johnAddress]
        )

        // Create Oublic group
        let group = try await userBob.chat.group.create(name: newName, options: groupOptions)
        XCTAssertEqual(group?.groupName, newName)

        // Member accepted
        let aliceRequests = try await userAlice.chat.list(type: .REQUESTS)
        XCTAssertEqual(aliceRequests.count, 1)
        let aliceAccepted = try await userAlice.chat.accept(target: group!.chatId)
        XCTAssertNotNil(aliceAccepted)
        let newAliceRequests = try await userAlice.chat.list(type: .REQUESTS)
        XCTAssertEqual(newAliceRequests.count, 0)
        let aliceChats = try await userAlice.chat.list(type: .CHAT)
        XCTAssertEqual(aliceChats.count, 1)

        // Member Status
        let aliceStatus = try await userAlice.chat.group.participants.status(chatId: group!.chatId, accountId: aliceAddress)
        XCTAssertEqual(aliceStatus.role, "MEMBER")
        XCTAssertEqual(aliceStatus.pending, false)
        XCTAssertEqual(aliceStatus.participant, true)

        let johnStatus = try await userJohn.chat.group.participants.status(chatId: group!.chatId, accountId: johnAddress)
        XCTAssertEqual(johnStatus.pending, false)
        XCTAssertEqual(johnStatus.participant, false)

        // Pending Members List (with pending included)
        let pendingMembers = try await userBob.chat.group.participants.list(chatId: group!.chatId, options: GroupParticipants.GetGroupParticipantsOptions(filter: GroupParticipants.FilterOptions(pending: true)
        ))

        XCTAssertEqual(pendingMembers?.count, 0)

        
        // Members List
        let groupMembers = try await userBob.chat.group.participants.list(chatId: group!.chatId)

        XCTAssertEqual(groupMembers?.count, 2)
    }
    
    
    func testAesEncryptDecrypt() async throws{
        let plaintext = "Hello, AES!"
        let secretKey = "0123456789abcdef"
        
//        let cipher = try aesEncrypt(plainText: plaintext, secretKey: secretKey)
        let cipher =  try AESCBCHelper.encrypt(messageText: plaintext, secretKey: secretKey)
        
        print("plaintext: \(plaintext), secretKey: \(secretKey), cipher: \(cipher)")
    }


}
