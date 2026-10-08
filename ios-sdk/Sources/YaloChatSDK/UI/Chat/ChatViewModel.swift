// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// Holds what the chat screen shows and turns what the person does into
/// stored messages.
///
/// A message is stored before it goes to the channel, so one the screen shows
/// is never lost to the network. The screen shows what storage holds rather
/// than a copy that could drift from it.
@MainActor
final class ChatViewModel: ObservableObject {
    static let pageSize: Int = 50

    @Published var draft: String = ""
    /// Oldest first.
    @Published private(set) var messages: [ChatMessage] = []

    private let chatMessages: ChatMessageService
    private let yaloMessages: YaloMessageRepository
    private let sessionId: String
    private let now: () -> Date

    init(
        chatMessages: ChatMessageService,
        yaloMessages: YaloMessageRepository,
        sessionId: String,
        now: @escaping () -> Date = { Date() }
    ) {
        self.chatMessages = chatMessages
        self.yaloMessages = yaloMessages
        self.sessionId = sessionId
        self.now = now
    }

    /// Runs the conversation for as long as the calling task lives.
    func start() async {
        // Listening comes first, so nothing said while connecting is missed.
        let incoming: AsyncStream<ChatMessage> = yaloMessages.messages()
        yaloMessages.connect()
        await loadMessages()
        for await message in incoming {
            await receive(message)
        }
        yaloMessages.close()
    }

    func send() async {
        let text: String = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            return
        }
        draft = ""
        let written: ChatMessage = ChatMessage(role: .user, type: .text, timestamp: now(), content: text)
        guard let stored = try? await chatMessages.insert(written, sessionId: sessionId) else {
            return
        }
        await loadMessages()
        try? await yaloMessages.send(stored)
    }

    /// The system takes the socket of an app in the background, so the line is
    /// dropped there and opened again on the way back.
    func onScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            yaloMessages.pause()
        case .active:
            yaloMessages.resume()
        default:
            break
        }
    }

    private func receive(_ message: ChatMessage) async {
        guard (try? await chatMessages.insert(message, sessionId: sessionId)) != nil else {
            return
        }
        await loadMessages()
    }

    private func loadMessages() async {
        guard let stored = try? await chatMessages.messages(sessionId: sessionId, limit: Self.pageSize) else {
            return
        }
        messages = stored.reversed()
    }
}
