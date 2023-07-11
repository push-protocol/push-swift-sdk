import Push
import XCTest

class UpdateGroupTest: XCTestCase {

  func testUpdateGroupChatAddingNewDescription() async throws {
    let chatId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    var group = try await PushChat.getGroup(chatId: chatId, env: .STAGING)!

    let newAddress = generateRandomEthereumAddress()
    let newGroupDesc = "Update with \(newAddress)"

    group.groupDescription = newGroupDesc
    group.members += group.pendingMembers

    let updatedGroup = try await PushChat.updateGroup(
      updatedGroup: group, adminAddress: UserAddress, adminPgpPrivateKey: UserPrivateKey,
      env: .STAGING)

    XCTAssertEqual(updatedGroup.groupDescription, newGroupDesc)
  }

  func testUpdateGroupChatAddingNewName() async throws {
    let chatId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    var group = try await PushChat.getGroup(chatId: chatId, env: .STAGING)!

    let newAddress = generateRandomEthereumAddress()
    let newName = "Chat \(newAddress)"

    group.groupName = newName
    let updatedGroup = try await PushChat.updateGroup(
      updatedGroup: group, adminAddress: UserAddress, adminPgpPrivateKey: UserPrivateKey,
      env: .STAGING)

    XCTAssertEqual(updatedGroup.groupName, group.groupName)
  }

  func testUpdateGroupChatAddingNewImage() async throws {
    let chatId = "064ae7a086bc1d25cf45231a9725fec6789e1013b99bb482f41136268ffa73c6"
    var group = try await PushChat.getGroup(chatId: chatId, env: .STAGING)!

    let newAddress = generateRandomEthereumAddress()
    let newImage =
      "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAIAAADTED8xAAADMElEQVR4nOzVwQnAIBQFQYXff81RUkQCOyDj1YOPnbXWPmeTRef+/3O/OyBjzh3CD95BfqICMK0CMK0CMK0CMK0C\(newAddress)"

    group.groupImage = newImage
    let updatedGroup = try await PushChat.updateGroup(
      updatedGroup: group, adminAddress: UserAddress, adminPgpPrivateKey: UserPrivateKey,
      env: .STAGING)

    XCTAssertEqual(updatedGroup.groupImage, group.groupImage)
  }

  // func testLeaveGroupChat() async throws {
  //   let chatId = "1ee2f0a0e6d9da6c1c6db460c1117013bbaa491c909ef3270e89dde2305a52a0"
  //   try await PushChat.leaveGroup(
  //     chatId: chatId, userAddress: UserAddress, userPgpPrivateKey: UserPrivateKey, env: .STAGING)
  // }

}
