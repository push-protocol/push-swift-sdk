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

    assert(message.messageContent != "")

    // print("got message \(message.messageContent)")
    // print(message)

  }

  func testPrivateGroupSendPrivateMessageText() async throws {
    let res = try await PushChat.send(
      PushChat.SendOptions(
        messageContent: "This is the test message",
        messageType: PushChat.MessageType.Text.rawValue,
        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY
      ))

    assert(res.cid != nil)
  }

  func testPrivateGroupSendPrivateMessageImage() async throws {
    let res = try await PushChat.send(
      PushChat.SendOptions(
        messageContent:
          "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAEa0lEQVR4nLzW+1OUVRwG8F1Ylk0YxSQuAxjIRRhDyiQJKHZlAkSlHQdwEkSTywgKCiKIqFsbYEFIGWhgCBKjJBexkSUFVAZowLxEEDeH5DJyWTccySsS9Dz9D7788DnM8L7Med5zzvd7JIPNVSKRKGf3Kqi3whTuezgMK+ySYOO2XhhVVAJjCwegW2otPHegCEpzCuCU4gWclWyEohEb4J2wFOYd4n/WE73iH3GB83EMVRF1MLjrJAwKMYJPVWvgyrsv4cWQbjgg2wQNI39kYvUDWONxE941/APWBsYxfXAxfHfOD8pS+oVIIMkpmsTwbDoAeo58CMfnzkJzBdfD3SKFcyn/G2Zd4hevdOMK7Y1xhGU9Q7DYfA/MtqqHC8Z00PTELFxrdV2IBGLT3EgMccqr8NjUQhgz4gp1hXegmToQOumpYHfrcpjyiwf8yCEG2id1wYXy23CDNh/+W38JOv7MNVNV7xIigaTVbQZDc1oFLLTjfNWKMOiXHgW981vgqMwcWml4DqQJLtA2k7tLmecDd56/BsvrTOCVDj7pnMi3IsOshEggznQ4jeGRXRZnF/8pPDPEE6CxWAy/lG6B+zRMNrF2Cta587ULdtWwN+UCrMzk6Zme3Q1VPf5wo88OeHNvhBAJJPHB3EUeS8theCRX36Wdq/JX91H4+XkvmHuQCWKmPoNJTs+howPz3dd+AjfZP2TWEp4hm7S3OOtrm+F4dpkgCRLl3AMHbpvBzmEZfOFVA5+FhkDftkdwsyd3yPrvNnDu9X/CXbZ8fnRsO8xuiIeVsXKY2voPLDTiSvQvmRQigXiy7wMM82ruopduofCLNms40MNd/PUM5/h8aBEsq2DFf3OSe8ml5XV4aM8YVH61Ghq6jEBXS24yLyXrkv/leUESnCwwwBAQzS8+Ge4Lw5s08NeJIbhM+huVsTdlRl+HUYd3wv1FXAPFOv7uWsuKm9U2Dqud0qHJa+/AG9+0CJFAIvbkTje16INjaq573Ag7VI+O31GryoDpIn1o4aOE377NZ94/fA/eql0HfQdOwMfbz8A+B55h/Sz+9UjnD4IkSJ65zPlaci5JInYxa18LOOHGKh/XxC5WOMiTuSYglZkW83lrB/asiw03YG40d1FxfzOU65pg4yr2tR0GWkESnNJwxXOcW+Hy+CVQv/cJ9KnkiZX/znuOmY0atqflwuDvuTY1Vy3hYCDzjSrkUBfUBtu2sB+UefJe5PnEUYgE4mmDKxiStzZCg845OFx6BCZ4bINdZzuhXx5rVOlj9on5kvdgRwZvc/kPeAJiU1h3w46zCjRXMU24P/vz0QYnIRJI7oc+xVCWztqtkS6D0nOsRUaLjsEIk63QfQXvHGErWXl+OsWdXvExu3HAAmN4K5nfOt57P6zTSvklug/CRON8IRKIlaGs+KtlrKah/3fgNzSlsNKEs6sb5c0n2YP91smSM1VlBEH7fFanMQXvpq7r2cXaT3OF7tzrgM5G7NiBxrZCJPgvAAD//zl2dP4g/Ks+AAAAAElFTkSuQmCC",
        messageType: "Image",

        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY
      ))

    assert(res.cid != nil)
  }

  func testPrivateGroupSendPrivateMessageReaction() async throws {

    let res_0 = try await PushChat.send(
      PushChat.SendOptions(
        messageContent: "This is the test message",
        messageType: PushChat.MessageType.Text.rawValue,
        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY
      ))

    let res = try await PushChat.send(
      PushChat.SendOptions(
        messageContent: PushChat.SendOptions.Reactions.THUMBSUP.rawValue,
        messageType: PushChat.MessageType.Reaction.rawValue,
        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY,
        refrence: res_0.cid!
      ))

    assert(res.cid != nil)

  }

  func testPrivateGroupSendPrivateMessageReply() async throws {
    let res_0 = try await PushChat.send(
      PushChat.SendOptions(
        messageContent: "This is the test message",
        messageType: PushChat.MessageType.Text.rawValue,
        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY
      ))

    let res = try await PushChat.send(
      PushChat.SendOptions(
        messageContent: "This is the reply message",
        messageType: PushChat.MessageType.Reply.rawValue,
        receiverAddress: PG_GROUP_ID,
        account: PG_USER,
        pgpPrivateKey: PG_PGP_KEY,
        refrence: res_0.cid!
      ))

    assert(res.cid != nil)

  }

}

let PG_USER = "0x45A6859F165edf0a55bE1246404D87f55D1A2a75"
let PG_GROUP_ID = "65247b1fe5b83e980d0cfced52d050afa4290918b41bd3ded04edc74214b25c0"

let PG_PGP_KEY = """
  -----BEGIN PGP PRIVATE KEY BLOCK-----

  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
  aLKX7DslUvWS3JV3SyuVqgMD2g==
  =oN+c
  -----END PGP PRIVATE KEY BLOCK-----
  """
