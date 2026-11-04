// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

enum YaloMessageRepositoryError: Error, Equatable {
    /// A message was sent while the chat was closed.
    case closed
    /// A kind of message that cannot go out yet.
    case unsupported(MessageType)
}

/// The channel's side of one conversation, in the terms the chat thinks in.
@MainActor
protocol YaloMessageRepository: AnyObject {
    /// Opens the line to the channel and rebuilds it whenever it is lost.
    /// Asking again while it is open changes nothing.
    func connect()

    /// Drops the line because the app went to the background, keeping
    /// whatever is waiting to be sent.
    func pause()

    /// Opens the line again after `pause()`.
    func resume()

    /// Ends the conversation and forgets whatever was waiting to be sent.
    func close()

    /// Drops the line and whatever was waiting to be sent, then opens a new
    /// one with the token asked for now. A paused line opens on `resume()`.
    func restart() async

    /// What the channel says from now on.
    func messages() -> AsyncStream<ChatMessage>

    /// Hands `message` to the channel. A message sent before the line is up
    /// goes out once it is.
    func send(_ message: ChatMessage) async throws

    /// Tells the channel a chat has been opened on an empty conversation, so
    /// it can say something first. `openContext` reaches the channel as it is
    /// given, and what it says back arrives through `messages()`.
    func requestGuidanceCard(openContext: [String: String]) async throws

    /// Tells the channel how the person rated its message `wiId`. Nil says
    /// they took their rating back.
    func sendFeedback(_ feedback: ChatMessage.Feedback?, wiId: String) async throws

    /// Commands the channel asks the host app to run, from now on.
    func commandRequests() -> AsyncStream<CommandRequest>

    /// Answers `request`: a success carries the payload back, a failure tells
    /// the channel the command did not run. A cart page that is not the JSON
    /// the channel expects is answered as a failure.
    func answerCommand(_ request: CommandRequest, result: Result<String, Error>) async throws
}
