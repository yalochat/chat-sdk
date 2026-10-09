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

    private func viewModel(replyTimeout: TimeInterval = 45, openContext: [String: String] = [:]) -> ChatViewModel {
        ChatViewModel(
            chatMessages: storage,
            yaloMessages: channel,
            voice: voice,
            media: MediaRepository(service: mediaService, tokens: TokenRepository(auth: CountingAuthService())),
            images: ImageDeviceService(directory: imagesDirectory),
            sessionId: "session-1",
            openContext: openContext,
            now: { Self.now },
            replyTimeout: replyTimeout
        )
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
