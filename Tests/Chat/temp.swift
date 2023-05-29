// import Foundation

// let signer = Signer(privateKey: "c39d17b1575c8d5e6e615767e19dc285d1f803d21882fb0c60f7f5b7edb759b2")
// let userAddress = "0xD26A7BF7fa0f8F1f3f73B056c9A67565A6aFE63c"
// let user = try await User.get(account: userAddress, env: .STAGING)!
// let pgpPrivateKey = try User.DecryptPGPKey(
//   encryptedPrivateKey: user.encryptedPrivateKey, signer: signer)

// let converationHash = try await Chats.ConversationHash(
//   conversationId:"0x4D5bE92D510300ceF50a2FC03534A95b60028950", account: userAddress)!
// print("converation has", converationHash)

// // let res = try await Chats.getMessagesService(threadHash: converationHash, limit: 1, env: .STAGING)
// let messages = try await Chats.History(
//   threadHash: converationHash,limit: 10, pgpPrivateKey: pgpPrivateKey, env: .STAGING)


// for msg in messages{
//   print(msg.messageContent) 
// }
