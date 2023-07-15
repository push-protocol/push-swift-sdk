import Push
import XCTest

class UpdateUserTests: XCTestCase {
  func testNameUpdateTest() async throws {
    var userProfile = try await Push.PushUser.get(account: UserAddress, env: .STAGING)!.profile
    userProfile.name = "name" + generateRandomEthereumAddress()

    try await PushUser.updateUserProfile(
      account: UserAddress, pgpPrivateKey: UserPrivateKey, newProfile: userProfile, env: .STAGING)
    let userProfileUpdated = try await Push.PushUser.get(account: UserAddress, env: .STAGING)!
      .profile

    XCTAssertEqual(userProfileUpdated.name, userProfile.name)

  }

  func testDescUpdateTest() async throws {
    var userProfile = try await Push.PushUser.get(account: UserAddress, env: .STAGING)!.profile
    userProfile.desc = "desc" + generateRandomEthereumAddress()

    try await PushUser.updateUserProfile(
      account: UserAddress, pgpPrivateKey: UserPrivateKey, newProfile: userProfile, env: .STAGING)
    let userProfileUpdated = try await Push.PushUser.get(account: UserAddress, env: .STAGING)!
      .profile

    XCTAssertEqual(userProfileUpdated.desc, userProfile.desc)

  }

  func testUserBlock() async throws {
    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]

    try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
  }

  func testUserUnBlock() async throws {
    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]
    let usersToUnBlock = [a1, a3]

    try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)

    try await PushUser.unblockUsers(
      addressesToUnblock: usersToUnBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
  }

}
