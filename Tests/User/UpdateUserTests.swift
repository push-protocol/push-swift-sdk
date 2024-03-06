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

  func testGenerateHash() async throws {

  let name = "null"
  let desc =  "null"
  let picture =  "\"name\""
  
  let blockUserAddresses = flatten_address_list(addresses: [])
    let jsonString =
    "{\"name\":\(name),\"desc\":\(desc),\"picture\":\(picture),\"blockedUsersList\":\(blockUserAddresses)}"


   let hash =  generateSHA256Hash(msg: jsonString)
   print(hash)
  }

  func testUserBlockForNewUser() async throws {
    let userPk1 = getRandomAccount()

    let signer1 = try SignerPrivateKey(privateKey: userPk1)

    let user1 = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.DEV,
        signer: SignerPrivateKey(
          privateKey: userPk1
        ),
        progressHook: nil
      ))
 

    let user1PpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user1.encryptedPrivateKey, signer: signer1)
    

    let (a1, a2, a3) = (
      generateRandomEthereumAddress(), generateRandomEthereumAddress(),
      generateRandomEthereumAddress()
    )

    let usersToBlock = [a1, a2, a3]

    try await PushUser.blockUsers(
      addressesToBlock: usersToBlock, account: user1.did, pgpPrivateKey: user1PpgpPk,
      env: .DEV)
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
