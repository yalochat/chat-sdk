// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
import YaloChatProto
@testable import YaloChatSDK

struct YaloMessageWebSocketServiceTests {
    private let opened: Recorded<FakeWebSocket> = Recorded()

    private func service(
        baseURL: URL = URL(string: "https://example.test/gateway")!,
        ackTimeout: TimeInterval = 2
    ) -> YaloMessageWebSocketService {
        let opened: Recorded<FakeWebSocket> = opened
        return YaloMessageWebSocketService(baseURL: baseURL, ackTimeout: ackTimeout) { url in
            let socket: FakeWebSocket = FakeWebSocket(url: url)
            opened.append(socket)
            return socket
        }
    }

    private func socket() async throws -> FakeWebSocket {
        #expect(await eventually { !opened.values.isEmpty })
        return try #require(opened.values.last)
    }

    private static func message(_ correlationId: String) -> SdkMessage {
        var message: SdkMessage = SdkMessage()
        message.correlationID = correlationId
        return message
    }

    private static func correlationIds(_ frames: [String]) throws -> [String] {
        try frames.map { frame in
            try SdkMessage(jsonString: frame).correlationID
        }
    }

    private static func textFrame(id: String) -> String {
        #"{"id":"\#(id)","message":{"textMessageRequest":{"content":{"text":"Hi"}}},"status":"DELIVERED"}"#
    }

    @Test(arguments: [
        ("https://example.test/gateway", "wss://example.test/gateway/websocket/v1/connect/inapp?token=token-1"),
        ("http://localhost:8080", "ws://localhost:8080/websocket/v1/connect/inapp?token=token-1"),
    ])
    func opensTheInAppSocketWithTheToken(baseURL: String, expected: String) async throws {
        let service: YaloMessageWebSocketService = service(baseURL: URL(string: baseURL)!)

        let running: Task<Bool, Never> = Task {
            await service.run(token: "token-1")
        }
        let socket: FakeWebSocket = try await socket()
        socket.close()

        #expect(socket.url.absoluteString == expected)
        #expect(await running.value == false)
    }

    @Test func answersTrueForAConnectionTheBackendAcknowledged() async throws {
        let service: YaloMessageWebSocketService = service()

        let running: Task<Bool, Never> = Task {
            await service.run(token: "token")
        }
        let socket: FakeWebSocket = try await socket()
        socket.push(FakeWebSocket.connectionAck)
        try await service.send(Self.message("live"))
        #expect(await eventually { !socket.sent.isEmpty })
        socket.close()

        #expect(await running.value == true)
    }

    @Test func givesUpOnAConnectionThatIsNeverAcknowledged() async throws {
        let service: YaloMessageWebSocketService = service(ackTimeout: 0.05)

        let acknowledged: Bool = await service.run(token: "token")

        #expect(acknowledged == false)
        #expect(try #require(opened.values.first).closed)
    }

    @Test func holdsWhatIsSentUntilTheConnectionIsAcknowledged() async throws {
        let service: YaloMessageWebSocketService = service()
        try await service.send(Self.message("first"))
        try await service.send(Self.message("second"))

        let running: Task<Bool, Never> = Task {
            await service.run(token: "token")
        }
        let socket: FakeWebSocket = try await socket()
        #expect(socket.sent.isEmpty)
        socket.push(FakeWebSocket.connectionAck)

        #expect(await eventually { socket.sent.count == 2 })
        #expect(try Self.correlationIds(socket.sent) == ["first", "second"])
        running.cancel()
    }

    @Test func closeForgetsWhatWasWaitingToBeSent() async throws {
        let service: YaloMessageWebSocketService = service()
        try await service.send(Self.message("forgotten"))
        await service.close()

        let running: Task<Bool, Never> = Task {
            await service.run(token: "token")
        }
        let socket: FakeWebSocket = try await socket()
        socket.push(FakeWebSocket.connectionAck)
        try await service.send(Self.message("kept"))

        #expect(await eventually { !socket.sent.isEmpty })
        #expect(try Self.correlationIds(socket.sent) == ["kept"])
        running.cancel()
    }

    @Test func deliversMessagesToEveryListenerAndSkipsEverythingElse() async throws {
        let service: YaloMessageWebSocketService = service()
        let listeners: [AsyncStream<PollMessageItem>] = [await service.messages(), await service.messages()]

        let running: Task<Bool, Never> = Task {
            await service.run(token: "token")
        }
        let socket: FakeWebSocket = try await socket()
        socket.push(FakeWebSocket.connectionAck)
        socket.push(Self.textFrame(id: "wi-1"))
        socket.push(#"{"type":"SDK_MESSAGE_ACK_TYPE_MESSAGE_ACK","correlationId":"1"}"#)
        socket.push(FakeWebSocket.connectionAck)
        socket.push("not json")
        socket.push(Self.textFrame(id: "wi-2"))

        for listener in listeners {
            var ids: [String] = []
            for await item in listener {
                ids.append(item.id)
                if ids.count == 2 {
                    break
                }
            }
            #expect(ids == ["wi-1", "wi-2"])
        }
        running.cancel()
    }

    @Test func cancellingTheRunClosesTheSocket() async throws {
        let service: YaloMessageWebSocketService = service()

        let running: Task<Bool, Never> = Task {
            await service.run(token: "token")
        }
        let socket: FakeWebSocket = try await socket()
        socket.push(FakeWebSocket.connectionAck)
        running.cancel()

        _ = await running.value
        #expect(socket.closed)
    }
}
