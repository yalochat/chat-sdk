// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftUI
import Testing
import UniformTypeIdentifiers
@testable import YaloChatSDK

@MainActor
struct ChatViewModelTests {
    private nonisolated static let now: Date = Date(timeIntervalSince1970: 1_700_000_000)
    private let storage: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: nil)
    private let channel: FakeYaloMessageRepository = FakeYaloMessageRepository()
    private let recorder: FakeVoiceRecorder = FakeVoiceRecorder()
    private let player: FakeVoicePlayer = FakeVoicePlayer()
    private let mediaService: FakeYaloMediaService = FakeYaloMediaService()
    private let voice: VoiceRepositoryLocal
    private let imagesDirectory: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-view-model-images-\(UUID().uuidString)", isDirectory: true)

    init() {
        voice = VoiceRepositoryLocal(
            recorder: recorder,
            player: player,
            directory: FileManager.default.temporaryDirectory
                .appendingPathComponent("yalo-chat-view-model-tests-\(UUID().uuidString)", isDirectory: true)
        )
    }

    private let ephemeralDirectory: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-view-model-ephemeral-\(UUID().uuidString)", isDirectory: true)
    private let run: ChatViewModel.Run = ChatViewModel.Run()
    private let tokenStore: FakeTokenStore = FakeTokenStore()

    private func viewModel(
        replyTimeout: TimeInterval = 45,
        openContext: [String: String] = [:],
        sessionId: String = "session-1",
        ephemeral: Bool = false,
        chatMessages: ChatMessageService? = nil,
        welcomeMessageType: WelcomeMessageType = .none,
        commands: [String: CommandHandler] = [:],
        clearRequests: @escaping () -> AsyncStream<Void> = { AsyncStream { continuation in continuation.finish() } }
    ) -> ChatViewModel {
        ChatViewModel(
            chatMessages: chatMessages ?? storage,
            yaloMessages: channel,
            voice: voice,
            media: MediaRepository(service: mediaService, tokens: TokenRepository(auth: CountingAuthService())),
            images: ImageDeviceService(directory: imagesDirectory),
            tokens: TokenRepository(auth: CountingAuthService(), store: tokenStore, sessionId: sessionId, ephemeral: ephemeral),
            sessionId: sessionId,
            ephemeral: ephemeral,
            ephemeralDirectory: ephemeralDirectory,
            run: run,
            openContext: openContext,
            welcomeMessageType: welcomeMessageType,
            commandHandlers: { command in commands[command] },
            clearRequests: clearRequests,
            now: { Self.now },
            replyTimeout: replyTimeout
        )
    }

    private func agentMessage(_ content: String, wiId: String = "wi-1", at timestamp: Date = Self.now) -> ChatMessage {
        ChatMessage(role: .agent, type: .text, timestamp: timestamp, wiId: wiId, content: content)
    }

    @Test func startShowsStoredMessagesInTheOrderTheyArrived() async throws {
        _ = try await storage.insert(agentMessage("first", at: Self.now), sessionId: "session-1")
        _ = try await storage.insert(agentMessage("second", wiId: "wi-2", at: Self.now.addingTimeInterval(-60)), sessionId: "session-1")
        _ = try await storage.insert(agentMessage("elsewhere", wiId: "wi-3"), sessionId: "session-2")
        let viewModel: ChatViewModel = viewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.map(\.content) == ["first", "second"] })
        running.cancel()
    }

    /// A started view model showing one stored message from the channel.
    private func ratingViewModel(_ stored: ChatMessage) async -> (ChatViewModel, Task<Void, Never>) {
        _ = try? await storage.insert(stored, sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel()
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        _ = await eventually { viewModel.messages.count == 1 }
        return (viewModel, running)
    }

    @Test func ratesAMessageAndKeepsTheRating() async throws {
        let (viewModel, running): (ChatViewModel, Task<Void, Never>) = await ratingViewModel(agentMessage("Hi"))

        await viewModel.rate(try #require(viewModel.messages.first), .thumbsUp)

        #expect(viewModel.messages.first?.feedback == .thumbsUp)
        #expect(try await storage.messages(sessionId: "session-1", limit: 10).first?.feedback == .thumbsUp)
        #expect(channel.feedbackSent.map(\.feedback) == [.thumbsUp])
        #expect(channel.feedbackSent.map(\.wiId) == ["wi-1"])
        running.cancel()
    }

    @Test func switchesToTheOtherRating() async throws {
        let (viewModel, running): (ChatViewModel, Task<Void, Never>) = await ratingViewModel(agentMessage("Hi"))

        await viewModel.rate(try #require(viewModel.messages.first), .thumbsUp)
        await viewModel.rate(try #require(viewModel.messages.first), .thumbsDown)

        #expect(viewModel.messages.first?.feedback == .thumbsDown)
        #expect(channel.feedbackSent.map(\.feedback) == [.thumbsUp, .thumbsDown])
        running.cancel()
    }

    @Test func pickingTheSameRatingAgainTakesItBack() async throws {
        let (viewModel, running): (ChatViewModel, Task<Void, Never>) = await ratingViewModel(agentMessage("Hi"))

        await viewModel.rate(try #require(viewModel.messages.first), .thumbsDown)
        await viewModel.rate(try #require(viewModel.messages.first), .thumbsDown)

        #expect(viewModel.messages.first?.feedback == nil)
        #expect(channel.feedbackSent.map(\.feedback) == [.thumbsDown, nil])
        running.cancel()
    }

    @Test func aRatingTheChannelCouldNotGetGoesBack() async throws {
        let (viewModel, running): (ChatViewModel, Task<Void, Never>) = await ratingViewModel(agentMessage("Hi"))
        await viewModel.rate(try #require(viewModel.messages.first), .thumbsUp)
        channel.sendError = YaloMessageRepositoryError.closed

        await viewModel.rate(try #require(viewModel.messages.first), .thumbsDown)

        #expect(viewModel.messages.first?.feedback == .thumbsUp)
        #expect(try await storage.messages(sessionId: "session-1", limit: 10).first?.feedback == .thumbsUp)
        running.cancel()
    }

    @Test func aMessageTheChannelDoesNotKnowCannotBeRated() async throws {
        let (viewModel, running): (ChatViewModel, Task<Void, Never>) = await ratingViewModel(
            ChatMessage(role: .agent, type: .text, timestamp: Self.now, content: "Hi")
        )

        await viewModel.rate(try #require(viewModel.messages.first), .thumbsUp)

        #expect(viewModel.messages.first?.feedback == nil)
        #expect(channel.feedbackSent.isEmpty)
        running.cancel()
    }

    @Test func runsTheCommandTheChannelAsksForAndAnswersWithItsResult() async throws {
        let viewModel: ChatViewModel = viewModel(commands: ["getStore": { payload in "store for \(payload)" }])
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.isListeningForCommands })

        channel.askForCommand(CommandRequest(correlationId: "c-1", commandId: "getStore", payload: "42"))

        #expect(await eventually { !channel.commandAnswers.isEmpty })
        let answer = try #require(channel.commandAnswers.first)
        #expect(answer.correlationId == "c-1")
        #expect(try answer.result.get() == "store for 42")
        running.cancel()
    }

    @Test func answersAFailedCommandWhenItsHandlerThrows() async throws {
        let viewModel: ChatViewModel = viewModel(commands: ["getStore": { _ in throw URLError(.cancelled) }])
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.isListeningForCommands })

        channel.askForCommand(CommandRequest(correlationId: "c-1", commandId: "getStore", payload: ""))

        #expect(await eventually { !channel.commandAnswers.isEmpty })
        let answer = try #require(channel.commandAnswers.first)
        #expect(throws: URLError.self) {
            try answer.result.get()
        }
        running.cancel()
    }

    @Test func leavesACommandNobodyRegisteredUnanswered() async throws {
        let viewModel: ChatViewModel = viewModel(commands: ["known": { _ in "done" }])
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.isListeningForCommands })

        channel.askForCommand(CommandRequest(correlationId: "c-1", commandId: "unknown", payload: ""))
        channel.askForCommand(CommandRequest(correlationId: "c-2", commandId: "known", payload: ""))

        #expect(await eventually { !channel.commandAnswers.isEmpty })
        #expect(channel.commandAnswers.map(\.correlationId) == ["c-2"])
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

    private func folder(of sessionId: String) -> URL {
        ephemeralDirectory.appendingPathComponent(sessionId, isDirectory: true)
    }

    private func stored(_ sessionId: String) async throws -> Int {
        try await storage.messages(sessionId: sessionId, limit: 10).count
    }

    /// Everything a conversation leaves on the device: a message, a file and a token.
    private func leaveBehind(_ sessionId: String, ephemeral: Bool = true) async throws {
        _ = try await storage.insert(agentMessage("old"), sessionId: sessionId)
        try FileManager.default.createDirectory(at: folder(of: sessionId), withIntermediateDirectories: true)
        try tokenStore.save(AuthToken(accessToken: "old", refreshToken: "", expiresAt: .distantFuture), sessionId: sessionId, ephemeral: ephemeral)
    }

    /// Starts `viewModel` and lets it run until the sweep has had its turn.
    private func run(_ viewModel: ChatViewModel) async {
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        _ = await eventually { channel.isListening && run.swept }
        running.cancel()
        await running.value
    }

    @Test(arguments: [false, true])
    func startForgetsWhatEarlierRunsLeftBehind(ephemeral: Bool) async throws {
        try await leaveBehind("abandoned")
        try await leaveBehind("remembered", ephemeral: false)

        await run(viewModel(ephemeral: ephemeral))

        #expect(await eventually { tokenStore.stored("abandoned") == nil })
        #expect(try await stored("abandoned") == 0)
        #expect(!FileManager.default.fileExists(atPath: folder(of: "abandoned").path))
        #expect(try await stored("remembered") == 1)
        #expect(tokenStore.stored("remembered") != nil)
    }

    @Test func theSweepKeepsTheConversationsOpenNow() async throws {
        let open: ChatViewModel = viewModel(sessionId: "open", ephemeral: true)
        try await leaveBehind("open")

        await run(viewModel())

        #expect(try await stored("open") == 1)
        #expect(tokenStore.stored("open") != nil)
        withExtendedLifetime(open) {}
    }

    @Test func theSweepRunsOnceARun() async throws {
        await run(viewModel())
        try await leaveBehind("abandoned")

        await run(viewModel())

        #expect(try await stored("abandoned") == 1)
    }

    @Test func anEphemeralConversationIsForgottenOnceTheChatIsGone() async throws {
        var viewModel: ChatViewModel? = viewModel(ephemeral: true)
        try await leaveBehind("session-1")
        await run(try #require(viewModel))

        viewModel = nil

        #expect(await eventually { tokenStore.stored("session-1") == nil })
        #expect(try await stored("session-1") == 0)
        #expect(!FileManager.default.fileExists(atPath: folder(of: "session-1").path))
    }

    @Test func aRememberedConversationOutlivesItsChat() async throws {
        var viewModel: ChatViewModel? = viewModel()
        try await leaveBehind("session-1", ephemeral: false)
        await run(try #require(viewModel))

        viewModel = nil
        try await Task.sleep(nanoseconds: 50_000_000)

        #expect(try await stored("session-1") == 1)
        #expect(tokenStore.stored("session-1") != nil)
    }

    @Test func aConversationWhoseMessagesCannotBeForgottenIsFoundAgain() async throws {
        let unreadable: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: unreadable, withIntermediateDirectories: true)
        try tokenStore.save(AuthToken(accessToken: "old", refreshToken: "", expiresAt: .distantFuture), sessionId: "abandoned", ephemeral: true)

        await run(viewModel(chatMessages: ChatMessageDatabaseService(fileURL: unreadable)))

        #expect(tokenStore.stored("abandoned") != nil)
    }

    @Test func anEmptyConversationAsksTheChannelToSpeakFirst() async {
        let viewModel: ChatViewModel = viewModel(openContext: ["sku": "37549996"])

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { channel.guidanceCardRequests == [["sku": "37549996"]] })
        #expect(viewModel.isWaitingForReply)
        running.cancel()
    }

    @Test func aConversationUnderWayIsNotOpenedAgain() async throws {
        _ = try await storage.insert(agentMessage("Hi"), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel(openContext: ["sku": "37549996"])

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.map(\.content) == ["Hi"] })
        #expect(channel.guidanceCardRequests.isEmpty)
        #expect(!viewModel.isWaitingForReply)
        running.cancel()
    }

    @Test func clearingEmptiesTheConversationAndOpensItAgain() async throws {
        _ = try await storage.insert(agentMessage("Hi"), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel(openContext: ["sku": "37549996"])
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { viewModel.messages.count == 1 })

        await viewModel.clearMessages()

        #expect(viewModel.messages.isEmpty)
        #expect(try await stored("session-1") == 0)
        #expect(channel.guidanceCardRequests == [["sku": "37549996"]])
        #expect(viewModel.isWaitingForReply)
        running.cancel()
    }

    @Test func clearingAnEmptyConversationDoesNotGreetTwice() async {
        let viewModel: ChatViewModel = viewModel()
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.guidanceCardRequests.count == 1 })

        await viewModel.clearMessages()

        #expect(channel.guidanceCardRequests.count == 1)
        running.cancel()
    }

    @Test func clearingKeepsTheConversationWhenStorageFails() async throws {
        let unreadable: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: unreadable, withIntermediateDirectories: true)
        let viewModel: ChatViewModel = viewModel(chatMessages: ChatMessageDatabaseService(fileURL: unreadable))

        await viewModel.clearMessages()

        #expect(channel.guidanceCardRequests.isEmpty)
    }

    @Test func aRunningChatClearsWhenTheHostAsks() async throws {
        let client: YaloChatClient = YaloChatClient(
            config: YaloChatClientConfig(channelId: "channel", organizationId: "organization", channelName: "Support"),
            chatMessages: storage
        )
        _ = try await storage.insert(agentMessage("Hi"), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel(clearRequests: client.clearRequests)
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { viewModel.messages.count == 1 })

        await client.clearMessages()

        #expect(await eventually { viewModel.messages.isEmpty })
        running.cancel()
    }

    @Test func waitsForNothingWhenTheChannelRefusesToOpen() async {
        channel.sendError = YaloMessageRepositoryError.closed
        let viewModel: ChatViewModel = viewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { channel.isListening })
        #expect(!viewModel.isWaitingForReply)
        running.cancel()
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

    private func offering(_ replies: [String], wiId: String, at timestamp: Date = Self.now) -> ChatMessage {
        ChatMessage(
            role: .agent,
            type: .text,
            timestamp: timestamp,
            wiId: wiId,
            content: "Pick one",
            buttons: replies.map { reply in MessageButton(text: reply) } + [MessageButton(text: "Menu", kind: .postback)]
        )
    }

    @Test func offersTheQuickRepliesOfTheNewestMessageThatHasThem() async throws {
        _ = try await storage.insert(offering(["Old"], wiId: "wi-1", at: Self.now.addingTimeInterval(-60)), sessionId: "session-1")
        let newest: ChatMessage = try await storage.insert(offering(["Yes", "No"], wiId: "wi-2", at: Self.now.addingTimeInterval(-30)), sessionId: "session-1")
        _ = try await storage.insert(agentMessage("Anything else?", wiId: "wi-3"), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.quickReplies.map(\.text) == ["Yes", "No"] })
        #expect(viewModel.quickRepliesMessageId == newest.id)
        running.cancel()
    }

    @Test func offersNothingOnceThePersonHasSpoken() async throws {
        _ = try await storage.insert(offering(["Yes"], wiId: "wi-1", at: Self.now.addingTimeInterval(-60)), sessionId: "session-1")
        _ = try await storage.insert(ChatMessage(role: .user, type: .text, timestamp: Self.now, content: "Maybe"), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.count == 2 })
        #expect(viewModel.quickReplies.isEmpty)
        #expect(viewModel.quickRepliesMessageId == nil)
        running.cancel()
    }

    @Test func offersTheQuickRepliesOfAReceivedMessage() async {
        let viewModel: ChatViewModel = viewModel()
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.isListening })

        channel.emit(offering(["Yes", "No"], wiId: "wi-1"))

        #expect(await eventually { viewModel.quickReplies.map(\.text) == ["Yes", "No"] })
        running.cancel()
    }

    @Test(arguments: [MessageButton(text: "Yes"), MessageButton(text: "Menu", kind: .postback)])
    func tappingAButtonSaysItsTextAndEndsTheOffer(button: MessageButton) async throws {
        _ = try await storage.insert(offering(["Yes"], wiId: "wi-1", at: Self.now.addingTimeInterval(-60)), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel()
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { !viewModel.quickReplies.isEmpty })
        viewModel.draft = "kept for later"

        await viewModel.tap(button)

        #expect(channel.sent.map(\.content) == [button.text])
        #expect(viewModel.messages.last?.content == button.text)
        #expect(viewModel.quickReplies.isEmpty)
        #expect(viewModel.draft == "kept for later")
        #expect(viewModel.isWaitingForReply)
        running.cancel()
    }

    @Test func theChannelsFirstMessageIsAWelcomeUntilThePersonAnswers() async throws {
        _ = try await storage.insert(offering(["Yes", "No"], wiId: "wi-1"), sessionId: "session-1")
        let viewModel: ChatViewModel = viewModel(welcomeMessageType: .verticalQuickReplies)
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { viewModel.isWelcome })

        await viewModel.tap(MessageButton(text: "Yes"))

        #expect(!viewModel.isWelcome)
        running.cancel()
    }

    @Test(arguments: [
        (WelcomeMessageType.none, 1),
        (.verticalQuickReplies, 2),
    ])
    func nothingIsAWelcomeUnlessAskedOrOnceTheChannelSaysMore(welcomeMessageType: WelcomeMessageType, said: Int) async throws {
        for index in 1...said {
            _ = try await storage.insert(offering(["Yes"], wiId: "wi-\(index)"), sessionId: "session-1")
        }
        let viewModel: ChatViewModel = viewModel(welcomeMessageType: welcomeMessageType)
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.count == said })
        #expect(!viewModel.isWelcome)
        running.cancel()
    }

    @Test func waitsForAReplyOnceAMessageIsSent() async {
        let viewModel: ChatViewModel = viewModel()
        #expect(!viewModel.isWaitingForReply)
        viewModel.draft = "Hello"

        await viewModel.send()

        #expect(viewModel.isWaitingForReply)
    }

    @Test func waitsForNothingWhenTheChannelRefusesTheMessage() async {
        let viewModel: ChatViewModel = viewModel()
        channel.sendError = YaloMessageRepositoryError.closed
        viewModel.draft = "Hello"

        await viewModel.send()

        #expect(!viewModel.isWaitingForReply)
    }

    @Test func stopsWaitingOnceAReplyArrives() async {
        let viewModel: ChatViewModel = viewModel()
        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }
        #expect(await eventually { channel.isListening })
        viewModel.draft = "Hello"
        await viewModel.send()

        channel.emit(agentMessage("Hi there"))

        #expect(await eventually { !viewModel.isWaitingForReply })
        running.cancel()
    }

    @Test func givesUpWaitingWhenNoReplyArrivesInTime() async {
        let viewModel: ChatViewModel = viewModel(replyTimeout: 0.01)
        viewModel.draft = "Hello"

        await viewModel.send()

        #expect(await eventually { !viewModel.isWaitingForReply })
    }

    @Test func aRecordingIsShownWhileItRuns() async {
        let viewModel: ChatViewModel = viewModel()

        await viewModel.startRecording()

        #expect(viewModel.recording?.amplitudes.count == 40)
    }

    @Test func sendingWhileRecordingStoresUploadsAndSendsTheNote() async throws {
        let viewModel: ChatViewModel = viewModel()
        viewModel.draft = "kept for later"
        await viewModel.startRecording()

        await viewModel.send()

        let shown: ChatMessage = try #require(viewModel.messages.last)
        let note: VoiceNote = try #require(shown.voice)
        let uploaded: MediaContent = try #require(await mediaService.uploads.first)
        let sent: ChatMessage = try #require(channel.sent.first)
        #expect(viewModel.recording == nil)
        #expect(viewModel.draft == "kept for later")
        #expect(shown.type == .voice)
        #expect(shown.role == .user)
        #expect(uploaded.fileName == note.fileName)
        #expect(uploaded.mimeType == "audio/mp4")
        #expect(sent.id == shown.id)
        #expect(sent.voice?.mediaURL == "media-1")
        #expect(viewModel.isWaitingForReply)
    }

    @Test func aNoteThatFailsToUploadIsShownButNotSent() async throws {
        let viewModel: ChatViewModel = viewModel()
        await mediaService.failUploads(with: [MediaServiceError.uploadFailed(status: 500)])
        await viewModel.startRecording()

        await viewModel.send()

        #expect(viewModel.messages.map(\.type) == [.voice])
        #expect(channel.sent.isEmpty)
        #expect(!viewModel.isWaitingForReply)
    }

    @Test func aCancelledRecordingIsNeitherShownNorSent() async {
        let viewModel: ChatViewModel = viewModel()
        await viewModel.startRecording()

        viewModel.cancelRecording()
        await viewModel.send()

        #expect(viewModel.recording == nil)
        #expect(viewModel.messages.isEmpty)
        #expect(channel.sent.isEmpty)
    }

    @Test func aRecordedNotePlaysFromTheDeviceAndPausesOnASecondTap() async throws {
        let viewModel: ChatViewModel = viewModel()
        await viewModel.startRecording()
        await viewModel.send()
        let shown: ChatMessage = try #require(viewModel.messages.last)

        await viewModel.toggleVoiceMessage(shown)
        #expect(viewModel.playback?.messageId == shown.id)
        #expect(viewModel.playback?.isPlaying == true)
        await viewModel.toggleVoiceMessage(shown)

        #expect(viewModel.playback?.isPlaying == false)
        #expect(await mediaService.downloads.isEmpty)
    }

    @Test func aNoteFromTheChannelIsDownloadedBeforePlaying() async throws {
        let viewModel: ChatViewModel = viewModel()
        let downloaded: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).ogg")
        await mediaService.serveDownloads(from: downloaded)
        let received: ChatMessage = ChatMessage(
            role: .agent,
            type: .voice,
            timestamp: Self.now,
            id: 5,
            voice: VoiceNote(duration: 3, mediaURL: "https://cdn/voice.ogg")
        )

        await viewModel.toggleVoiceMessage(received)

        #expect(await mediaService.downloads == ["https://cdn/voice.ogg"])
        #expect(player.loaded == downloaded)
        #expect(viewModel.playback?.messageId == 5)
    }

    @Test func aNoteThatIsNowhereDoesNotPlay() async {
        let viewModel: ChatViewModel = viewModel()
        let unreachable: ChatMessage = ChatMessage(role: .agent, type: .voice, timestamp: Self.now, id: 5, voice: VoiceNote(duration: 3))

        await viewModel.toggleVoiceMessage(unreachable)
        await viewModel.toggleVoiceMessage(agentMessage("Not a voice note"))

        #expect(viewModel.playback == nil)
        #expect(await mediaService.downloads.isEmpty)
    }

    private static func pickedPicture() throws -> NSItemProvider {
        let file: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        try Data("picture bytes".utf8).write(to: file)
        let provider: NSItemProvider = NSItemProvider()
        provider.suggestedName = "holiday"
        provider.registerFileRepresentation(forTypeIdentifier: UTType.jpeg.identifier, visibility: .all) { completion in
            completion(file, false, nil)
            return nil
        }
        return provider
    }

    @Test func aPickedPictureIsStoredUploadedAndSent() async throws {
        let viewModel: ChatViewModel = viewModel()

        await viewModel.sendImage(try Self.pickedPicture())

        let shown: ChatMessage = try #require(viewModel.messages.last)
        let picture: ImageAttachment = try #require(shown.image)
        let uploaded: MediaContent = try #require(await mediaService.uploads.first)
        let sent: ChatMessage = try #require(channel.sent.first)
        #expect(shown.type == .image)
        #expect(shown.role == .user)
        #expect(picture.fileName == "holiday.jpeg")
        #expect(picture.mimeType == "image/jpeg")
        #expect(picture.byteCount == 13)
        #expect(picture.localFileName == uploaded.fileURL.lastPathComponent)
        #expect(uploaded.fileURL.deletingLastPathComponent().standardizedFileURL == imagesDirectory.standardizedFileURL)
        #expect(sent.id == shown.id)
        #expect(sent.image?.mediaURL == "media-1")
        #expect(viewModel.isWaitingForReply)
    }

    @Test func aPictureThatFailsToUploadIsShownButNotSent() async throws {
        let viewModel: ChatViewModel = viewModel()
        await mediaService.failUploads(with: [MediaServiceError.uploadFailed(status: 500)])

        await viewModel.sendImage(try Self.pickedPicture())

        #expect(viewModel.messages.map(\.type) == [.image])
        #expect(channel.sent.isEmpty)
        #expect(!viewModel.isWaitingForReply)
    }

    @Test func somethingThatIsNotAPictureIsNeitherShownNorSent() async {
        let viewModel: ChatViewModel = viewModel()

        await viewModel.sendImage(NSItemProvider())

        #expect(viewModel.messages.isEmpty)
        #expect(await mediaService.uploads.isEmpty)
        #expect(channel.sent.isEmpty)
    }

    private static func png() throws -> URL {
        let file: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).png")
        let format: UIGraphicsImageRendererFormat = UIGraphicsImageRendererFormat()
        format.scale = 1
        try UIGraphicsImageRenderer(size: CGSize(width: 4, height: 3), format: format).pngData { context in
            context.fill(CGRect(x: 0, y: 0, width: 4, height: 3))
        }.write(to: file)
        return file
    }

    @Test func aSentPictureIsReadFromTheDevice() async throws {
        let viewModel: ChatViewModel = viewModel()
        let file: URL = try Self.png()
        let provider: NSItemProvider = NSItemProvider()
        provider.registerFileRepresentation(forTypeIdentifier: UTType.png.identifier, visibility: .all) { completion in
            completion(file, false, nil)
            return nil
        }
        await viewModel.sendImage(provider)

        let shown: ChatMessage = try #require(viewModel.messages.last)
        let picture: UIImage = try #require(await viewModel.image(of: shown))

        #expect(picture.size == CGSize(width: 4, height: 3))
        #expect(await mediaService.downloads.isEmpty)
    }

    @Test func aPictureFromTheChannelIsDownloaded() async throws {
        let viewModel: ChatViewModel = viewModel()
        await mediaService.serveDownloads(from: try Self.png())
        let received: ChatMessage = ChatMessage(
            role: .agent,
            type: .image,
            timestamp: Self.now,
            id: 5,
            image: ImageAttachment(mediaURL: "https://cdn/menu.png")
        )

        let picture: UIImage? = await viewModel.image(of: received)

        #expect(picture != nil)
        #expect(await mediaService.downloads == ["https://cdn/menu.png"])
    }

    @Test func aPictureIsReadOnceAndThenKept() async throws {
        let viewModel: ChatViewModel = viewModel()
        await mediaService.serveDownloads(from: try Self.png())
        let received: ChatMessage = ChatMessage(
            role: .agent,
            type: .image,
            timestamp: Self.now,
            id: 5,
            image: ImageAttachment(mediaURL: "https://cdn/menu.png")
        )
        #expect(viewModel.cachedImage(of: received) == nil)

        let first: UIImage? = await viewModel.image(of: received)
        let second: UIImage? = await viewModel.image(of: received)

        #expect(first != nil)
        #expect(second === first)
        #expect(viewModel.cachedImage(of: received) === first)
        #expect(await mediaService.downloads == ["https://cdn/menu.png"])
    }

    @Test func aPictureThatIsNowhereReadsAsNothing() async {
        let viewModel: ChatViewModel = viewModel()
        let unreachable: ChatMessage = ChatMessage(role: .agent, type: .image, timestamp: Self.now, id: 5, image: ImageAttachment())

        #expect(await viewModel.image(of: unreachable) == nil)
        #expect(await viewModel.image(of: agentMessage("Not a picture")) == nil)
        #expect(await mediaService.downloads.isEmpty)
    }

    @Test func goingToTheBackgroundStopsTheMicrophoneAndTheSpeaker() async throws {
        let viewModel: ChatViewModel = viewModel()
        let file: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).m4a")
        await viewModel.startRecording()
        try await voice.play(1, file: file)

        viewModel.onScenePhaseChange(.background)

        #expect(viewModel.recording == nil)
        #expect(!player.isPlaying)
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
