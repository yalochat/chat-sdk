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
    private(set) var feedbackSent: [(feedback: ChatMessage.Feedback?, wiId: String)] = []
    var sendError: Error?
    private(set) var commandAnswers: [(correlationId: String, result: Result<String, Error>)] = []
    private var listener: AsyncStream<ChatMessage>.Continuation?
    private var commandListener: AsyncStream<CommandRequest>.Continuation?

    var isListeningForCommands: Bool {
        commandListener != nil
    }

    func askForCommand(_ request: CommandRequest) {
        commandListener?.yield(request)
    }

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

    func commandRequests() -> AsyncStream<CommandRequest> {
        let (stream, continuation): (AsyncStream<CommandRequest>, AsyncStream<CommandRequest>.Continuation) =
            AsyncStream.makeStream()
        commandListener = continuation
        return stream
    }

    func answerCommand(_ request: CommandRequest, result: Result<String, Error>) async throws {
        commandAnswers.append((request.correlationId, result))
    }

    func requestGuidanceCard(openContext: [String: String]) async throws {
        if let sendError {
            throw sendError
        }
        guidanceCardRequests.append(openContext)
    }

    func sendFeedback(_ feedback: ChatMessage.Feedback?, wiId: String) async throws {
        if let sendError {
            throw sendError
        }
        feedbackSent.append((feedback, wiId))
    }
}
