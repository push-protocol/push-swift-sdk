import Push
import XCTest

class SocketClientTests: XCTestCase {
    func testConnection() async throws {
        let options = SocketInputOptions(
            user: "0x6A34eB3a649355335a22bd8Ae0da0a6b209277B7",
            env: ENV.STAGING,
            socketType: .chat,
            socketOptions: SocketOptions(
            ))

        let manager = try SocketClient.createSocketConnection(options)
        
    
        print("createSocketConnection: manager: \(manager)")
        

        let socket = manager.defaultSocket
        socket.on(clientEvent: .error) { data, ack in
            print("Socket error \(data)")
        }
        print("createSocketConnection: manager: \(socket.sid)")

        socket.connect(
            timeoutAfter: 15, 
            withHandler: {
            print("*** Failed to connect")
        })
        

        try await Task.sleep(nanoseconds: UInt64(5 * 1000000000))

        print("socket connected status 1 \(socket.status)")
        try await Task.sleep(nanoseconds: UInt64(5 * 1000000000))

        print("socket connected status 2 \(socket.status)")
        try await Task.sleep(nanoseconds: UInt64(5 * 1000000000))

        print("socket connected status 3 \(socket.status)")
        try await Task.sleep(nanoseconds: UInt64(5 * 1000000000))

        print("socket connected status 4 \(socket.status)")
        try await Task.sleep(nanoseconds: UInt64(5 * 1000000000))

        print("socket connected status 5 \(socket.status)")
//        print("socket connected status \(socket.e)")
//        print("socket connected status \(socket.config)")
    }

    func testPushStream() async throws {
        let alicePk = "a59c37c9b61b73f824972b901e0b4ae914750fd8de94c5dfebc4934ff1d12d3c" /// getRandomAccount()
        let bobPk = "0ab2b8f38a851c8e8782119fd1e202290b5c86736506525acde7b404260beba7" // getRandomAccount()
        let johnPk = getRandomAccount()
        print("alicePk: \(alicePk)")
        print("bobPk: \(bobPk)")

        // Initialize signers
        let aliceSigner = try SignerPrivateKey(privateKey: alicePk)
        let bobSigner = try SignerPrivateKey(privateKey: bobPk)
        let johnSigner = try SignerPrivateKey(privateKey: johnPk)

        // Store Address
        let aliceAddress = try await aliceSigner.getAddress()
        let bobAddress = try await bobSigner.getAddress()
        let johnAddress = try await johnSigner.getAddress()

        var userAlice = try await PushAPI
            .initializePush(
                signer: aliceSigner,
                options: PushAPI.PushAPIInitializeOptions(
                    env: .STAGING)
            )

        let stream = try userAlice.initStream(
            listen: [STREAM.CHAT, STREAM.CHAT_OPS],
            options: PushStreamInitializeOptions(
                filter: PushStreamFilter(
                    channels: ["*"],
                    chats: ["*"]
                )
            )
        )
        
        stream.on(STREAM.CONNECT.rawValue, listener: {it in
            print("Scocket connected: \(it)")
        }) 
        
        stream.on(STREAM.DISCONNECT.rawValue, listener: {it in
            print("Scocket DISCONNECT: \(it)")
        }) 
        
        stream.on("log", listener: {it in
            print("Scocket log : \(it)")
        })
        
      try await stream.connect()
        
        try await Task.sleep(nanoseconds: UInt64(20 * 1000000000))

        print("socket connected status \(stream)")
        
        
    }
}
