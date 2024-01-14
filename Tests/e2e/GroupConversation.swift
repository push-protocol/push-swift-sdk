import Push
import XCTest

class GroupFullConversation: XCTestCase {

  func testGroupFullConvesation() async throws {

    let userPk1 = getRandomAccount()
    let userPk2 = getRandomAccount()

    let signer1 = try SignerPrivateKey(privateKey: userPk1)
    let signer2 = try SignerPrivateKey(privateKey: userPk2)

    let address1 = try await signer1.getAddress()
    let address2 = try await signer2.getAddress()

    let user1 = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: SignerPrivateKey(
          privateKey: userPk1
        ),
        progressHook: nil
      ))

    let user2 = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: SignerPrivateKey(
          privateKey: userPk2
        ),
        progressHook: nil
      ))

    let user1PpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user1.encryptedPrivateKey, signer: signer1)
    let user2PpgpPk = try await PushUser.DecryptPGPKey(
      encryptedPrivateKey: user2.encryptedPrivateKey, signer: signer2)

    let createGroupOptions = try PushChat.CreateGroupOptions(
      name: "Group \(address1)",
      description: "Group with \(address1) & others",
      image:
        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O///2Anhf4QtqobAAAAAElFTkSuQmCC",
      members: [address2],
      isPublic: false,
      creatorAddress: address1,
      creatorPgpPrivateKey: user1PpgpPk,
      env: ENV.STAGING
    )

    let createdGroup = try await PushChat.createGroup(options: createGroupOptions)

    // user 2 joins the group
    let res = try await Push.PushChat.approve(
      PushChat.ApproveOptions(
        requesterAddress: createdGroup.chatId, approverAddress: address2, privateKey: user2PpgpPk,
        env: .STAGING))

    let newGroup = try await PushChat.getGroupInfoDTO(
      chatId: createdGroup.chatId, env: ENV.STAGING)!

    XCTAssert(newGroup.sessionKey!.count > 0)
    XCTAssert(res.contains(address1))
    XCTAssert(res.contains(address2))
  }
}
