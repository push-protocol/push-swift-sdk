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

  func testUserBlockExistingUser() async throws {
    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]

    try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
  }

  func testUserBlockCreatedUser() async throws {
    let userPk = getRandomAccount()
    let signer = try SignerPrivateKey(
      privateKey: userPk
    )
    let addrs = try await signer.getAddress()

    let user = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: signer,
        progressHook: nil
      ))

     let userPpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)


    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]

    try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: addrs, pgpPrivateKey: userPpgpPk,
      env: .STAGING)
  }

  func testUserUnBlockExistingUser() async throws {
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

  func testUserUnBlockCreatedUser() async throws {
    let userPk = getRandomAccount()
    let signer = try SignerPrivateKey(
      privateKey: userPk
    )
    let addrs = try await signer.getAddress()

    let user = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: signer,
        progressHook: nil
      ))

     let userPpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)


    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]
    let usersToUnBlock = [a1,a3]

    try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: addrs, pgpPrivateKey: userPpgpPk,
      env: .STAGING)
    
    try await PushUser.unblockUsers(
      addressesToUnblock: usersToUnBlock, account: UserAddress, pgpPrivateKey: UserPrivateKey,
      env: .STAGING)
  }

}
