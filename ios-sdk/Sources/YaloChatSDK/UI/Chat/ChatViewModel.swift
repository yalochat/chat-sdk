// Copyright (c) Yalochat, Inc. All rights reserved.

import Combine
import SwiftUI

/// Holds what the chat screen shows and turns what the person does into
/// stored messages.
///
/// A message is stored before it goes to the channel, so one the screen shows
/// is never lost to the network. The screen shows what storage holds rather
/// than a copy that could drift from it.
///
/// `recording` and `playback` change many times a second, so only the parts
/// of the screen that draw a waveform should read them.
///
/// An ephemeral conversation is forgotten once its chat is gone. The stored
/// token is what says a conversation was ephemeral, as in the Android SDK, so
/// it is forgotten last: one that could not be forgotten whole is found again
/// by the sweep of the next run.
@MainActor
final class ChatViewModel: ObservableObject {
    /// What one run of the app knows about its ephemeral conversations.
    @MainActor
    final class Run {
        var open: Set<String> = []
        var swept: Bool = false
    }

    static let pageSize: Int = 50
    static let run: Run = Run()

    @Published var draft: String = ""
    /// Oldest first.
    @Published private(set) var messages: [ChatMessage] = []
    /// A message went out and nothing has come back yet.
    @Published private(set) var isWaitingForReply: Bool = false
    /// The voice note being recorded, or nil when the microphone is idle.
    @Published private(set) var recording: VoiceRecording?
    /// The voice note being listened to, or nil when nothing is loaded.
    @Published private(set) var playback: VoicePlayback?

    private let chatMessages: ChatMessageService
    private let yaloMessages: YaloMessageRepository
    private let voice: VoiceRepository
    private let media: MediaRepository
    private let images: ImageService
    private let tokens: TokenRepository
    private let sessionId: String
    private let ephemeral: Bool
    /// Where each ephemeral conversation keeps its files, a folder per session.
    private let ephemeralDirectory: URL
    private let run: Run
    private let openContext: [String: String]
    private let now: () -> Date
    /// Seconds the loader waits before deciding no reply is coming.
    private let replyTimeout: TimeInterval
    private var replyDeadline: Task<Void, Never>?
    /// Pictures already read, by message id. The list drops a row that scrolls
    /// away, so this is what lets it come back drawn instead of loading again.
    /// Bounded by bytes, and emptied by the system when memory runs low.
    private let pictures: NSCache<NSNumber, UIImage> = {
        let cache: NSCache<NSNumber, UIImage> = NSCache()
        cache.totalCostLimit = 100 * 1_024 * 1_024
        return cache
    }()

    init(
        chatMessages: ChatMessageService,
        yaloMessages: YaloMessageRepository,
        voice: VoiceRepository,
        media: MediaRepository,
        images: ImageService,
        tokens: TokenRepository,
        sessionId: String,
        ephemeral: Bool = false,
        ephemeralDirectory: URL,
        run: Run,
        openContext: [String: String] = [:],
        now: @escaping () -> Date = { Date() },
        replyTimeout: TimeInterval = 45
    ) {
        self.chatMessages = chatMessages
        self.yaloMessages = yaloMessages
        self.voice = voice
        self.media = media
        self.images = images
        self.tokens = tokens
        self.sessionId = sessionId
        self.ephemeral = ephemeral
        self.ephemeralDirectory = ephemeralDirectory
        self.run = run
        self.openContext = openContext
        self.now = now
        self.replyTimeout = replyTimeout
        voice.recording.assign(to: &$recording)
        voice.playback.assign(to: &$playback)
        if ephemeral {
            // Said before any sweep reads, so a sweep never takes it.
            run.open.insert(sessionId)
        }
    }

    /// The chat is gone for good rather than off screen, which is what ends
    /// an ephemeral conversation.
    deinit {
        guard ephemeral else {
            return
        }
        let (run, sessionId): (Run, String) = (run, sessionId)
        let (chatMessages, tokens, directory): (ChatMessageService, TokenRepository, URL) = (chatMessages, tokens, ephemeralDirectory)
        Task { @MainActor in
            run.open.remove(sessionId)
            await Self.forget([sessionId], chatMessages: chatMessages, tokens: tokens, ephemeralDirectory: directory)
        }
    }

    /// Runs the conversation for as long as the calling task lives.
    func start() async {
        // Not tied to the screen, so leaving it does not cut the sweep short.
        Task {
            await sweepAbandoned()
        }
        // Listening comes first, so nothing said while connecting is missed.
        let incoming: AsyncStream<ChatMessage> = yaloMessages.messages()
        yaloMessages.connect()
        // Storage failing says nothing about whether the person has been here
        // before, and greeting them twice is worse than not greeting them.
        if let stored = await loadMessages(), stored.isEmpty {
            await openConversation()
        }
        for await message in incoming {
            await receive(message)
        }
        yaloMessages.close()
        voice.release()
    }

    /// Sends the recording when one is being made and the draft otherwise,
    /// since the same button does both.
    func send() async {
        if recording != nil {
            await sendRecording()
            return
        }
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
        await deliver(stored)
    }

    func startRecording() async {
        try? await voice.startRecording()
    }

    func cancelRecording() {
        voice.cancelRecording()
    }

    /// Plays `message`, or pauses it when it is the one already playing. A note
    /// the channel sent is downloaded first.
    func toggleVoiceMessage(_ message: ChatMessage) async {
        guard let id = message.id, let note = message.voice else {
            return
        }
        if let playback, playback.messageId == id, playback.isPlaying {
            voice.pausePlayback()
            return
        }
        var file: URL? = voice.file(of: note)
        if file == nil, !note.mediaURL.isEmpty {
            file = try? await media.download(note.mediaURL)
        }
        guard let file else {
            return
        }
        try? await voice.play(id, file: file)
    }

    /// The note is shown before it goes anywhere, like a typed message. The
    /// channel is told the id the upload answered with, so the upload comes first.
    private func sendRecording() async {
        guard let note = try? voice.stopRecording() else {
            return
        }
        let recorded: ChatMessage = ChatMessage(role: .user, type: .voice, timestamp: now(), voice: note)
        guard let stored = try? await chatMessages.insert(recorded, sessionId: sessionId) else {
            return
        }
        await loadMessages()
        guard
            let file = voice.file(of: note),
            let uploaded = try? await media.upload(MediaContent(fileURL: file, fileName: note.fileName, mimeType: note.mimeType))
        else {
            return
        }
        var sending: ChatMessage = stored
        sending.voice?.mediaURL = uploaded.id
        await deliver(sending)
    }

    /// Sends the picture the person picked out of the photo library. A copy is
    /// taken first, so the picture is in the conversation before it has been
    /// anywhere, and the upload comes before the send for the same reason a
    /// voice note's does.
    func sendImage(_ picked: NSItemProvider) async {
        guard let content = try? await images.content(picked) else {
            return
        }
        let byteCount: Int = (try? content.fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        let picture: ImageAttachment = ImageAttachment(
            mimeType: content.mimeType,
            fileName: content.fileName,
            byteCount: Int64(byteCount),
            localFileName: content.fileURL.lastPathComponent
        )
        let picked: ChatMessage = ChatMessage(role: .user, type: .image, timestamp: now(), image: picture)
        guard let stored = try? await chatMessages.insert(picked, sessionId: sessionId) else {
            return
        }
        await loadMessages()
        guard let uploaded = try? await media.upload(content) else {
            return
        }
        var sending: ChatMessage = stored
        sending.image?.mediaURL = uploaded.id
        await deliver(sending)
    }

    /// The picture of `message`, from the device for one the person sent and
    /// downloaded for one the channel sent, or nil when it is nowhere.
    func image(of message: ChatMessage) async -> UIImage? {
        if let cached = cachedImage(of: message) {
            return cached
        }
        guard let picture = message.image else {
            return nil
        }
        var file: URL? = images.file(of: picture)
        if file == nil, !picture.mediaURL.isEmpty {
            file = try? await media.download(picture.mediaURL)
        }
        guard let file, let read = await images.image(at: file) else {
            return nil
        }
        if let id = message.id {
            let bytes: Int = read.cgImage.map { image in image.bytesPerRow * image.height } ?? 0
            pictures.setObject(read, forKey: NSNumber(value: id), cost: bytes)
        }
        return read
    }

    /// The picture of `message` when it has already been read, without waiting.
    func cachedImage(of message: ChatMessage) -> UIImage? {
        message.id.flatMap { id in
            pictures.object(forKey: NSNumber(value: id))
        }
    }

    /// Lets the channel speak first, with what the chat was opened from to go on.
    private func openConversation() async {
        guard (try? await yaloMessages.requestGuidanceCard(openContext: openContext)) != nil else {
            return
        }
        waitForReply()
    }

    private func deliver(_ message: ChatMessage) async {
        // Nothing is coming back for a message the channel never took.
        guard (try? await yaloMessages.send(message)) != nil else {
            return
        }
        waitForReply()
    }

    /// The system takes the socket of an app in the background, so the line is
    /// dropped there and opened again on the way back. The microphone and the
    /// speaker stop too, since nobody should be recorded or talked to from a
    /// screen they left.
    func onScenePhaseChange(_ phase: ScenePhase) {
        switch phase {
        case .background:
            yaloMessages.pause()
            voice.pausePlayback()
            voice.cancelRecording()
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
        stopWaitingForReply()
        await loadMessages()
    }

    /// Sending again starts the wait over, so the newest message sets the deadline.
    private func waitForReply() {
        replyDeadline?.cancel()
        isWaitingForReply = true
        let timeout: UInt64 = UInt64(replyTimeout * 1_000_000_000)
        replyDeadline = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: timeout)
            } catch {
                return
            }
            self?.isWaitingForReply = false
        }
    }

    private func stopWaitingForReply() {
        replyDeadline?.cancel()
        replyDeadline = nil
        isWaitingForReply = false
    }

    /// Forgets the ephemeral conversations earlier runs of the app left
    /// behind, once a run. It runs in every mode, since an app that moved off
    /// ephemeral is the one case where nothing else would reach them.
    private func sweepAbandoned() async {
        guard !run.swept else {
            return
        }
        run.swept = true
        let abandoned: [String] = await tokens.ephemeralSessions().filter { sessionId in
            !run.open.contains(sessionId)
        }
        guard !abandoned.isEmpty else {
            return
        }
        await Self.forget(abandoned, chatMessages: chatMessages, tokens: tokens, ephemeralDirectory: ephemeralDirectory)
    }

    private static func forget(
        _ sessionIds: [String],
        chatMessages: ChatMessageService,
        tokens: TokenRepository,
        ephemeralDirectory: URL
    ) async {
        guard (try? await chatMessages.deleteSessions(sessionIds)) != nil else {
            return
        }
        for sessionId in sessionIds {
            try? FileManager.default.removeItem(at: ephemeralDirectory.appendingPathComponent(sessionId, isDirectory: true))
        }
        try? await tokens.deleteSessions(sessionIds)
    }

    @discardableResult
    private func loadMessages() async -> [ChatMessage]? {
        guard let stored = try? await chatMessages.messages(sessionId: sessionId, limit: Self.pageSize) else {
            return nil
        }
        messages = stored.reversed()
        return stored
    }
}
