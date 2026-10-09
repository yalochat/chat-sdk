// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
@testable import YaloChatSDK

@MainActor
final class FakeYaloMessageRepository: YaloMessageRepository {
    private(set) var connects: Int = 0
    private(set) var pauses: Int = 0
    private(set) var resumes: Int = 0
    private(set) var closes: Int = 0
    private(set) var sent: [ChatMessage] = []
    private(set) var guidanceCardRequests: [[String: String]] = []
    var sendError: Error?
    private var listener: AsyncStream<ChatMessage>.Continuation?

    var isListening: Bool {
        listener != nil
    }

    func emit(_ message: ChatMessage) {
        listener?.yield(message)
    }

    func connect() {
        connects += 1
    }

    func pause() {
        pauses += 1
    }

    func resume() {
        resumes += 1
    }

    func close() {
        closes += 1
    }

    func messages() -> AsyncStream<ChatMessage> {
        let (stream, continuation): (AsyncStream<ChatMessage>, AsyncStream<ChatMessage>.Continuation) =
            AsyncStream.makeStream()
        listener = continuation
        return stream
    }

    func send(_ message: ChatMessage) async throws {
        if let sendError {
            throw sendError
        }
        sent.append(message)
    }

    func requestGuidanceCard(openContext: [String: String]) async throws {
        if let sendError {
            throw sendError
        }
        guidanceCardRequests.append(openContext)
    }
}
