import Push
import XCTest

class PrivateGroupSendRead: XCTestCase {
  let env = ENV.STAGING

  func testPrivateGroupFetchConvesation() async throws {

    // conversation hash are also called link inside chat messages
    let converationHash = try await PushChat.ConversationHash(
      conversationId: PG_GROUP_ID,
      account: PG_USER,
      env: env
    )!

    let message = try await PushChat.Latest(
      threadHash: converationHash,
      pgpPrivateKey: PG_PGP_KEY,
      toDecrypt: true,
      env: env
    )

    print("got message \(message.messageContent)")
    print(message)

  }

  func testPrivateGroupSendAAA() async throws {

    let res = try await PushChat.send(
      PushChat.SendOptions(
        messageContent: "This is the test message",
        messageType: "Text",
        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY
      ))

    print("got msg", res)

  }
}

let PG_USER = "0xc95fE6BC0eC97aFA7adF2e98628caC6ec28Bb04c"
let PG_GROUP_ID = "ed3046965676e2118f452aa21318e527bec662dece05f63003e934c116b13e7d"
let PG_PGP_KEY = """
  -----BEGIN PGP PRIVATE KEY BLOCK-----

  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
  QdNy/dq7bCBplsE0k/pBwxs/AQ==
  =svYB
  -----END PGP PRIVATE KEY BLOCK-----

  """
