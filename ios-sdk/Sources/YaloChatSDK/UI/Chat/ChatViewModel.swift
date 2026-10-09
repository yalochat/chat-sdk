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
@MainActor
final class ChatViewModel: ObservableObject {
    static let pageSize: Int = 50

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
    private let sessionId: String
    private let now: () -> Date
    /// Seconds the loader waits before deciding no reply is coming.
    private let replyTimeout: TimeInterval
    private var replyDeadline: Task<Void, Never>?

    init(
        chatMessages: ChatMessageService,
        yaloMessages: YaloMessageRepository,
        voice: VoiceRepository,
        media: MediaRepository,
        sessionId: String,
        now: @escaping () -> Date = { Date() },
        replyTimeout: TimeInterval = 45
    ) {
        self.chatMessages = chatMessages
        self.yaloMessages = yaloMessages
        self.voice = voice
        self.media = media
        self.sessionId = sessionId
        self.now = now
        self.replyTimeout = replyTimeout
        voice.recording.assign(to: &$recording)
        voice.playback.assign(to: &$playback)
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

    private func loadMessages() async {
        guard let stored = try? await chatMessages.messages(sessionId: sessionId, limit: Self.pageSize) else {
            return
        }
        messages = stored.reversed()
    }
}
