// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftProtobuf
import YaloChatProto

/// Keeps a line to the channel open and translates between `ChatMessage` and
/// the wire format.
///
/// When a connection dies another one is opened with a fresh token, waiting a
/// little longer after each attempt the backend did not accept.
@MainActor
final class YaloMessageRepositoryRemote: YaloMessageRepository {
    private enum Lifecycle {
        case closed
        case running
        case paused
    }

    private static let maxBackoff: TimeInterval = 30
    private static let maxAttempt: Int = 5

    private let service: YaloMessageService
    private let tokens: TokenRepository
    private let now: @Sendable () -> Date
    private let sleep: @Sendable (TimeInterval) async throws -> Void
    private var lifecycle: Lifecycle = .closed
    private var connecting: Task<Void, Never>?

    init(
        service: YaloMessageService,
        tokens: TokenRepository,
        now: @escaping @Sendable () -> Date = { Date() },
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }
    ) {
        self.service = service
        self.tokens = tokens
        self.now = now
        self.sleep = sleep
    }

    func connect() {
        guard lifecycle == .closed else {
            return
        }
        lifecycle = .running
        startConnecting()
    }

    func pause() {
        guard lifecycle == .running else {
            return
        }
        lifecycle = .paused
        connecting?.cancel()
        connecting = nil
    }

    func resume() {
        guard lifecycle == .paused else {
            return
        }
        lifecycle = .running
        startConnecting()
    }

    func close() {
        lifecycle = .closed
        connecting?.cancel()
        connecting = nil
        Task { [service] in
            await service.close()
        }
    }

    func messages() -> AsyncStream<ChatMessage> {
        let service: YaloMessageService = service
        let now: @Sendable () -> Date = now
        return AsyncStream { continuation in
            let listening: Task<Void, Never> = Task {
                for await item in await service.messages() {
                    if let message = Self.chatMessage(from: item, now: now()) {
                        continuation.yield(message)
                    }
                }
                continuation.finish()
            }
            continuation.onTermination = { _ in
                listening.cancel()
            }
        }
    }

    func send(_ message: ChatMessage) async throws {
        guard lifecycle != .closed else {
            throw YaloMessageRepositoryError.closed
        }
        guard message.type == .text else {
            throw YaloMessageRepositoryError.unsupported(message.type)
        }
        try await service.send(Self.textMessage(from: message, sentAt: now()))
    }

    private func startConnecting() {
        let service: YaloMessageService = service
        let tokens: TokenRepository = tokens
        let sleep: @Sendable (TimeInterval) async throws -> Void = sleep
        connecting = Task {
            await Self.connectUntilStopped(service: service, tokens: tokens, sleep: sleep)
        }
    }

    // A token is fetched for every attempt, since the last one may have run out while it was up.
    private static func connectUntilStopped(
        service: YaloMessageService,
        tokens: TokenRepository,
        sleep: @Sendable (TimeInterval) async throws -> Void
    ) async {
        var attempt: Int = 0
        while !Task.isCancelled {
            if let token = try? await tokens.token(), !Task.isCancelled, await service.run(token: token) {
                // The line worked, so the waits start over.
                attempt = 0
            }
            do {
                try await sleep(min(maxBackoff, pow(2, Double(attempt))))
            } catch {
                return
            }
            attempt = min(attempt + 1, maxAttempt)
        }
    }

    private static func textMessage(from message: ChatMessage, sentAt: Date) -> SdkMessage {
        var content: Yalo_ExternalChannel_InApp_Sdk_V2_TextMessage = .init()
        content.text = message.content
        // When it was written, which is not when it goes out.
        content.timestamp = Google_Protobuf_Timestamp(date: message.timestamp)
        content.role = .user
        content.status = .inProgress
        var request: Yalo_ExternalChannel_InApp_Sdk_V2_TextMessageRequest = .init()
        request.timestamp = Google_Protobuf_Timestamp(date: sentAt)
        request.content = content
        var envelope: SdkMessage = SdkMessage()
        // The row id, so an acknowledgement names the row it belongs to.
        envelope.correlationID = message.id.map(String.init) ?? UUID().uuidString
        envelope.timestamp = Google_Protobuf_Timestamp(date: sentAt)
        envelope.payload = .textMessageRequest(request)
        return envelope
    }

    /// Only text so far. Anything else is left out rather than shown empty.
    private static func chatMessage(from item: PollMessageItem, now: Date) -> ChatMessage? {
        guard case .textMessageRequest(let request) = item.message.payload else {
            return nil
        }
        return ChatMessage(
            role: .agent,
            type: .text,
            timestamp: item.hasDate ? item.date.date : now,
            wiId: item.id,
            content: request.content.text,
            status: ChatMessage.Status(rawValue: item.status) ?? .delivered,
            header: request.hasHeader ? request.header : nil,
            footer: request.hasFooter ? request.footer : nil
        )
    }
}
