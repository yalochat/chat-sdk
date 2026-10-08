// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatViewModelTests {
    private nonisolated static let now: Date = Date(timeIntervalSince1970: 1_700_000_000)
    private let storage: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: nil)
    private let channel: FakeYaloMessageRepository = FakeYaloMessageRepository()

    private func viewModel() -> ChatViewModel {
        ChatViewModel(chatMessages: storage, yaloMessages: channel, sessionId: "session-1", now: { Self.now })
    }

    private func agentMessage(_ content: String, wiId: String = "wi-1", at timestamp: Date = Self.now) -> ChatMessage {
        ChatMessage(role: .agent, type: .text, timestamp: timestamp, wiId: wiId, content: content)
    }

    @Test func startShowsStoredMessagesOldestFirst() async throws {
        _ = try await storage.insert(agentMessage("second", wiId: "wi-2", at: Self.now), sessionId: "session-1")
        _ = try await storage.insert(agentMessage("first", at: Self.now.addingTimeInterval(-60)), sessionId: "session-1")
        _ = try await storage.insert(agentMessage("elsewhere", wiId: "wi-3"), sessionId: "session-2")
        let viewModel: ChatViewModel = viewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.map(\.content) == ["first", "second"] })
        running.cancel()
    }

    @Test func startConnectsAndClosesOnceItsTaskEnds() async {
        let viewModel: ChatViewModel = viewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.connects == 1 })
        running.cancel()
        await running.value

        #expect(channel.closes == 1)
    }

    @Test func sendStoresShowsAndSendsTheTrimmedDraft() async throws {
        let viewModel: ChatViewModel = viewModel()
        viewModel.draft = "  Hello  "

        await viewModel.send()

        let shown: ChatMessage = try #require(viewModel.messages.last)
        #expect(viewModel.draft.isEmpty)
        #expect(shown.id != nil)
        #expect(shown.role == .user)
        #expect(shown.content == "Hello")
        #expect(shown.timestamp == Self.now)
        #expect(channel.sent == [shown])
    }

    @Test(arguments: ["", "  \n "])
    func sendIgnoresABlankDraft(draft: String) async {
        let viewModel: ChatViewModel = viewModel()
        viewModel.draft = draft

        await viewModel.send()

        #expect(viewModel.messages.isEmpty)
        #expect(channel.sent.isEmpty)
    }

    @Test func sendKeepsTheMessageWhenTheChannelRefusesIt() async {
        let viewModel: ChatViewModel = viewModel()
        channel.sendError = YaloMessageRepositoryError.closed
        viewModel.draft = "Hello"

        await viewModel.send()

        #expect(viewModel.messages.map(\.content) == ["Hello"])
    }

    @Test func receivedMessagesAreStoredAndShownOnce() async throws {
        let viewModel: ChatViewModel = viewModel()
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.isListening })

        channel.emit(agentMessage("Hi there"))
        channel.emit(agentMessage("Hi there"))
        channel.emit(agentMessage("Anything else?", wiId: "wi-2", at: Self.now.addingTimeInterval(1)))

        #expect(await eventually { viewModel.messages.map(\.content) == ["Hi there", "Anything else?"] })
        let stored: [ChatMessage] = try await storage.messages(sessionId: "session-1", limit: 10)
        #expect(stored.count == 2)
        running.cancel()
    }

    @Test func theLineFollowsTheAppInAndOutOfTheBackground() {
        let viewModel: ChatViewModel = viewModel()

        viewModel.onScenePhaseChange(.inactive)
        viewModel.onScenePhaseChange(.background)
        viewModel.onScenePhaseChange(.active)

        #expect(channel.pauses == 1)
        #expect(channel.resumes == 1)
    }
}
