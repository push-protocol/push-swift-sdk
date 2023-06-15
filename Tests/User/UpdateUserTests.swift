import Push
import XCTest

class UpdateUserTests: XCTestCase {

  func testUserProfileNameTest() async throws {
    let newProfile = PushUser.UpdatedUserProfile(
      blockedUsersList: [generateRandomEthereumAddress()])
    
    let success = try await PushUser.updateUserProfile(
      account: UserAddress, pgpPrivateKey: UserPrivateKey, updatedProfile: newProfile, env: .STAGING
    )
    
    XCTAssert(success)
  }

  func testUserBlock() async throws {
    let (a1,a2,a3) = ( generateRandomEthereumAddress(), generateRandomEthereumAddress(), generateRandomEthereumAddress())
    let usersToBlock = ["0x25B6C189a90443F899998Bd84CF14FABEC684aa6"]
    
    let res = try await PushUser.blockUsers(addressesToBlock: usersToBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey, env: .STAGING)
    XCTAssert(res)
  }

}
