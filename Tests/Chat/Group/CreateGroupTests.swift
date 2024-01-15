import Foundation
import Push
import XCTest

class CreateGroupTest: XCTestCase {
  // func testCreatePublicGroupChat() async throws {
  //   let anotherUser = generateRandomEthereumAddress()

  //   let userPk = getRandomAccount()
  //   let signer = try SignerPrivateKey(
  //     privateKey: userPk
  //   )
  //   let addrs = try await signer.getAddress()

  //   let user = try await PushUser.create(
  //     options: PushUser.CreateUserOptions(
  //       env: ENV.STAGING,
  //       signer: SignerPrivateKey(
  //         privateKey: userPk
  //       ),
  //       progressHook: nil
  //     ))

  //   let pgpPK = try await Push.PushUser.DecryptPGPKey(
  //     encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)

  //   let createGroupOptions = try PushChat.CreateGroupOptions(
  //     name: "Group \(anotherUser)",
  //     description: "Group with \(anotherUser) & others",
  //     image:
  //       "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O/OyBjzh3CD95BfqICMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMO0TAAD//2Anhf4QtqobAAAAAElFTkSuQmCC",
  //     members: [anotherUser],
  //     isPublic: true,
  //     creatorAddress: addrs,
  //     creatorPgpPrivateKey: pgpPK,
  //     env: ENV.STAGING
  //   )

  //   let createdGroup = try await PushChat.createGroup(options: createGroupOptions)
  //   XCTAssertEqual(createdGroup.groupName, createGroupOptions.name)
  //   XCTAssertEqual(createdGroup.isPublic, true)
  //   XCTAssertEqual(createdGroup.groupCreator, walletToPCAIP10(account: addrs))
  //   XCTAssertEqual(createdGroup.pendingMembers[0].wallet, walletToPCAIP10(account: anotherUser))
  // }

  func testCreatePrivateGroupChat() async throws {
    let anotherUser = generateRandomEthereumAddress()

    let userPk = getRandomAccount()
    let signer = try SignerPrivateKey(
      privateKey: userPk
    )
    let addrs = try await signer.getAddress()

    let user = try await PushUser.create(
      options: PushUser.CreateUserOptions(
        env: ENV.STAGING,
        signer: SignerPrivateKey(
          privateKey: userPk
        ),
        progressHook: nil
      ))

    let pgpPK = try await Push.PushUser.DecryptPGPKey(
      encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)

    let createGroupOptions = try PushChat.CreateGroupOptions(
      name: "Group \(anotherUser)",
      description: "Group with \(anotherUser) & others",
      image:
        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O/OyBjzh3CD95BfqICMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMK0CMO0TAAD//2Anhf4QtqobAAAAAElFTkSuQmCC",
      members: [anotherUser],
      isPublic: false,
      creatorAddress: addrs,
      creatorPgpPrivateKey: pgpPK,
      env: ENV.STAGING
    )

    let createdGroup = try await PushChat.createGroup(options: createGroupOptions)

    XCTAssertEqual(createdGroup.groupName, createGroupOptions.name)
    XCTAssertEqual(createdGroup.isPublic, false)
    XCTAssertEqual(createdGroup.groupCreator, walletToPCAIP10(account: addrs))

    print("created group ", createdGroup)
  }
}
