import Push
import XCTest

class UpdateUserTests: XCTestCase {

  // func testUserProfileNameTest() async throws {
  //   let newProfile = PushUser.UpdatedUserProfile(
  //     blockedUsersList: [generateRandomEthereumAddress()])

  //   let success = try await PushUser.updateUserProfile(
  //     account: UserAddress, pgpPrivateKey: UserPrivateKey, updatedProfile: newProfile, env: .STAGING
  //   )

  //   XCTAssert(success)
  // }

  func testUserBlock() async throws {
    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]

    let res = try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
    XCTAssert(res)
  }

  func testUserUnBlock() async throws {
    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]
    let usersToUnBlock = [a1, a3]

    let res1 = try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
    XCTAssert(res1)

    let res2 = try await PushUser.unblockUsers(
      addressesToUnblock: usersToUnBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
    XCTAssert(res2)
  }

}
