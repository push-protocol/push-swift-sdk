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
        let address = try await signer.getAddress()

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
    
    
}
