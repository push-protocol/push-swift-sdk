import Push
import XCTest

class OptChannelTests: XCTestCase {

  func testOptIn() async throws {
    let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"

    let mockSigner = MockEIP712OptinSigner()
    let userAddress = try await mockSigner.getAddress()

    let res = try await PushChannel.subscribe(
      option: PushChannel.SubscribeOption(
        signer: mockSigner, channelAddress: channelAddress, env: .STAGING))
    
    let isOptIn = try await PushChannel.getIsSubscribed(userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)
    
    XCTAssertEqual(res, true)
    XCTAssertEqual(isOptIn, true)
  }

  func testOptOut() async throws {
    let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
    let mockSigner = MockEIP712OptoutSigner()
    let userAddress = try await mockSigner.getAddress()

    let res = try await PushChannel.unsubscribe(
      option: PushChannel.SubscribeOption(
        signer: mockSigner, channelAddress: channelAddress, env: .STAGING))
    
    let isOptIn = try await PushChannel.getIsSubscribed(userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)
    
    XCTAssertEqual(isOptIn, false)
    XCTAssertEqual(res, true)
  }
  
  func testOptInOptOut() async throws{

    let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
    let mockSignerIn = MockEIP712OptinSigner()
    let mockSignerOut = MockEIP712OptoutSigner()

    let userAddress = try await mockSignerIn.getAddress()

    let _ = try await PushChannel.subscribe(
      option: PushChannel.SubscribeOption(
        signer: mockSignerIn, channelAddress: channelAddress, env: .STAGING))
    
    var isOptIn = try await PushChannel.getIsSubscribed(userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)    
    XCTAssertEqual(isOptIn, true)

     let _ = try await PushChannel.unsubscribe(
      option: PushChannel.SubscribeOption(
        signer: mockSignerOut, channelAddress: channelAddress, env: .STAGING))
   
    

    isOptIn = try await PushChannel.getIsSubscribed(userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)
    XCTAssertEqual(isOptIn, false)

    let _ = try await PushChannel.subscribe(
      option: PushChannel.SubscribeOption(
        signer: mockSignerIn, channelAddress: channelAddress, env: .STAGING))
    
    isOptIn = try await PushChannel.getIsSubscribed(userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)    
    XCTAssertEqual(isOptIn, true)

     let _ = try await PushChannel.unsubscribe(
      option: PushChannel.SubscribeOption(
        signer: mockSignerOut, channelAddress: channelAddress, env: .STAGING))
   
    

    isOptIn = try await PushChannel.getIsSubscribed(userAddress: userAddress, channelAddress: channelAddress, env: .STAGING)
    XCTAssertEqual(isOptIn, false)
  }

  func testSubscribers() async throws {
    let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
    

    let res = try await PushChannel.getSubscribers(option: PushChannel.GetChannelSubscribersOptions(channel: channelAddress, page: 0, limit: 20, env: .STAGING))

    XCTAssert(res.itemcount > 0)
    XCTAssert(res.subscribers.count > 0)
  }
    
    

}
