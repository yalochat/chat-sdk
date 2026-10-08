// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftProtobuf
import Testing
import YaloChatProto
@testable import YaloChatSDK

private actor FakeYaloMessageService: YaloMessageService {
    private(set) var runs: [String] = []
    private(set) var sent: [SdkMessage] = []
    private(set) var closes: Int = 0
    private var listeners: [AsyncStream<PollMessageItem>.Continuation] = []
    private let acknowledges: Bool

    init(acknowledges: Bool = false) {
        self.acknowledges = acknowledges
    }

    var listenerCount: Int {
        listeners.count
    }

    func emit(_ item: PollMessageItem) {
        for listener in listeners {
            listener.yield(item)
        }
    }

    func messages() -> AsyncStream<PollMessageItem> {
        let (stream, continuation): (AsyncStream<PollMessageItem>, AsyncStream<PollMessageItem>.Continuation) =
            AsyncStream.makeStream()
        listeners.append(continuation)
        return stream
    }

    func run(token: String) async -> Bool {
        runs.append(token)
        return acknowledges
    }

    func send(_ message: SdkMessage) async throws {
        sent.append(message)
    }

    func close() {
        closes += 1
    }
}

private struct StaticAuthService: YaloMessageAuthService {
    func authenticate() async throws -> AuthToken {
        AuthToken(accessToken: "access", refreshToken: "", expiresAt: .distantFuture)
    }

    func refresh(_ refreshToken: String) async throws -> AuthToken {
        try await authenticate()
    }
}

@MainActor
struct YaloMessageRepositoryRemoteTests {
    private nonisolated static let now: Date = Date(timeIntervalSince1970: 1_700_000_100)
    // A stream rather than a deadline, so a slow machine only makes the tests slower.
    private let delays: AsyncStream<TimeInterval>
    private let waited: AsyncStream<TimeInterval>.Continuation

    init() {
        (delays, waited) = AsyncStream.makeStream()
    }

    private func repository(_ service: FakeYaloMessageService) -> YaloMessageRepositoryRemote {
        let waited: AsyncStream<TimeInterval>.Continuation = waited
        return YaloMessageRepositoryRemote(
            service: service,
            tokens: TokenRepository(auth: StaticAuthService()),
            now: { Self.now },
            sleep: { seconds in
                waited.yield(seconds)
                try await Task.sleep(nanoseconds: 1_000_000)
            }
        )
    }

    private func firstDelays(_ count: Int) async -> [TimeInterval] {
        var first: [TimeInterval] = []
        for await delay in delays.prefix(count) {
            first.append(delay)
        }
        return first
    }

    private static func textItem(
        id: String = "wi-1",
        text: String = "Hello",
        date: Date? = Date(timeIntervalSince1970: 1_700_000_000),
        status: String = "READ"
    ) -> PollMessageItem {
        var request: Yalo_ExternalChannel_InApp_Sdk_V2_TextMessageRequest = .init()
        request.content.text = text
        request.header = "Header"
        var item: PollMessageItem = PollMessageItem()
        item.id = id
        item.status = status
        item.message.payload = .textMessageRequest(request)
        if let date {
            item.date = Google_Protobuf_Timestamp(date: date)
        }
        return item
    }

    @Test func connectRunsConnectionsWithTheToken() async {
        let service: FakeYaloMessageService = FakeYaloMessageService()
        let repository: YaloMessageRepositoryRemote = repository(service)

        repository.connect()

        #expect(await eventually { await service.runs.first == "access" })
        repository.close()
    }

    @Test func waitsLongerAfterEachRefusedConnectionUpToThirtySeconds() async {
        let service: FakeYaloMessageService = FakeYaloMessageService(acknowledges: false)
        let repository: YaloMessageRepositoryRemote = repository(service)

        // Twice, to show a second call does not open a second line.
        repository.connect()
        repository.connect()

        #expect(await firstDelays(7) == [1, 2, 4, 8, 16, 30, 30])
        repository.close()
    }

    @Test func startsTheWaitsOverAfterAnAcceptedConnection() async {
        let service: FakeYaloMessageService = FakeYaloMessageService(acknowledges: true)
        let repository: YaloMessageRepositoryRemote = repository(service)

        repository.connect()

        #expect(await firstDelays(3) == [1, 1, 1])
        repository.close()
    }

    @Test func pauseStopsConnectingAndResumeStartsAgain() async throws {
        let service: FakeYaloMessageService = FakeYaloMessageService()
        let repository: YaloMessageRepositoryRemote = repository(service)
        repository.connect()
        #expect(await eventually { await !service.runs.isEmpty })

        repository.pause()
        // An attempt already on its way may still land, so wait for the count to settle.
        #expect(await eventually {
            let before: Int = await service.runs.count
            try? await Task.sleep(nanoseconds: 50_000_000)
            return await service.runs.count == before
        })
        let runsWhenPaused: Int = await service.runs.count

        repository.resume()
        #expect(await eventually { await service.runs.count > runsWhenPaused })
        repository.close()
    }

    @Test func closeForgetsWhatWasWaiting() async {
        let service: FakeYaloMessageService = FakeYaloMessageService()
        let repository: YaloMessageRepositoryRemote = repository(service)
        repository.connect()

        repository.close()

        #expect(await eventually { await service.closes == 1 })
    }

    @Test func sendsTextInTheWireFormat() async throws {
        let service: FakeYaloMessageService = FakeYaloMessageService()
        let repository: YaloMessageRepositoryRemote = repository(service)
        let written: Date = Date(timeIntervalSince1970: 1_700_000_000)
        repository.connect()

        try await repository.send(ChatMessage(role: .user, type: .text, timestamp: written, id: 7, content: "Hello"))

        let sent: SdkMessage = try #require(await service.sent.first)
        guard case .textMessageRequest(let request) = sent.payload else {
            Issue.record("expected a text message request")
            return
        }
        #expect(sent.correlationID == "7")
        #expect(sent.timestamp.date == Self.now)
        #expect(request.timestamp.date == Self.now)
        #expect(request.content.text == "Hello")
        #expect(request.content.timestamp.date == written)
        #expect(request.content.role == .user)
        #expect(request.content.status == .inProgress)
        repository.close()
    }

    @Test func refusesToSendWhileClosed() async {
        let repository: YaloMessageRepositoryRemote = repository(FakeYaloMessageService())

        await #expect(throws: YaloMessageRepositoryError.closed) {
            try await repository.send(ChatMessage(role: .user, type: .text, timestamp: Self.now, content: "Hello"))
        }
    }

    @Test func refusesKindsItCannotSendYet() async {
        let repository: YaloMessageRepositoryRemote = repository(FakeYaloMessageService())
        repository.connect()

        await #expect(throws: YaloMessageRepositoryError.unsupported(.image)) {
            try await repository.send(ChatMessage(role: .user, type: .image, timestamp: Self.now))
        }
        repository.close()
    }

    @Test func turnsTextFromTheChannelIntoAgentMessages() async {
        let service: FakeYaloMessageService = FakeYaloMessageService()
        let repository: YaloMessageRepositoryRemote = repository(service)
        var image: PollMessageItem = PollMessageItem()
        image.message.payload = .imageMessageRequest(.init())

        let messages: AsyncStream<ChatMessage> = repository.messages()
        #expect(await eventually { await service.listenerCount == 1 })
        await service.emit(image)
        await service.emit(Self.textItem())
        await service.emit(Self.textItem(id: "wi-2", date: nil, status: ""))

        var received: [ChatMessage] = []
        for await message in messages {
            received.append(message)
            if received.count == 2 {
                break
            }
        }
        #expect(received == [
            ChatMessage(
                role: .agent,
                type: .text,
                timestamp: Date(timeIntervalSince1970: 1_700_000_000),
                wiId: "wi-1",
                content: "Hello",
                status: .read,
                header: "Header"
            ),
            ChatMessage(
                role: .agent,
                type: .text,
                timestamp: Self.now,
                wiId: "wi-2",
                content: "Hello",
                status: .delivered,
                header: "Header"
            ),
        ])
    }
}
