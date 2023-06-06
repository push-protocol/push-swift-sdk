import Push
import XCTest

class GetChannelTests: XCTestCase {

  func testGetExistingChannel() async throws {
    let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
    let res = try await PushChannel.getChannel(
      options: PushChannel.GetChannelOption(channel: channelAddress, env: .STAGING))!
    XCTAssertEqual(res.channel, channelAddress)
  }

  func testGetNonExistingChannel() async throws {
    let channelAddress = "0xcD23560D4F9F816Ffb3D790e5ac3f6A316c559Ea"
    let res = try await PushChannel.getChannel(
      options: PushChannel.GetChannelOption(channel: channelAddress, env: .STAGING))

    XCTAssert(res == nil)
  }

  func testGetChannels() async throws {
    let res = try await PushChannel.getChannels(option: PushChannel.GetChannelsOptions(page: 1, limit: 10, env:.STAGING))

    XCTAssert(res.itemcount > 0)
    XCTAssert(res.channels.count == 10)
  }
}
