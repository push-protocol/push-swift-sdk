import Push
import XCTest

class SearchChannelTests: XCTestCase {

  func testChannelByAddress() async throws {
    let channelAddress = "0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78"
    let res = try await PushChannel.search(option: PushChannel.SearchsOptions(query: channelAddress, page: 1, limit: 11, env: .STAGING) )
    
    XCTAssert(res.itemcount > 0)
    XCTAssertEqual(res.channels.first!.channel,channelAddress)
  }

  func testChannelByName() async throws {
    let query = "rayan"
    let res = try await PushChannel.search(option: PushChannel.SearchsOptions(query: query, page: 1, limit: 11, env: .STAGING) )
    
    XCTAssert(res.itemcount > 0)
  }

  func testNotExistingChannel() async throws {
    let query = "ra0x2AEcb6DeE3652dA1dD6b54D5fd4f7D8F43DaEb78yan"
    let res = try await PushChannel.search(option: PushChannel.SearchsOptions(query: query, page: 1, limit: 11, env: .STAGING) )
    
    XCTAssert(res.itemcount == 0)
  }
  
}
