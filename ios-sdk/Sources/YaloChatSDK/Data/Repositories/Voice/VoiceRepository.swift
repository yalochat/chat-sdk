// Copyright (c) Yalochat, Inc. All rights reserved.

import Combine
import Foundation

/// A recording being made. `amplitudes` is a window on the last few seconds,
/// so the waveform moves while somebody speaks.
struct VoiceRecording: Equatable, Sendable {
    let elapsed: TimeInterval
    let amplitudes: [Float]
}

/// A voice note being listened to, and how far in it is.
struct VoicePlayback: Equatable, Sendable {
    let messageId: Int64
    var position: TimeInterval
    let duration: TimeInterval
    var isPlaying: Bool
}

enum VoiceRepositoryError: Error, Equatable {
    /// The recording was too short to hold anything, so nothing was kept.
    case nothingRecorded
}

/// The microphone and the speaker, as one thing, since only one of them can be
/// in use: starting a recording stops whatever was playing.
@MainActor
protocol VoiceRepository: AnyObject {
    /// The recording under way, or nil when the microphone is idle.
    var recording: AnyPublisher<VoiceRecording?, Never> { get }

    /// The note being listened to, or nil when nothing is loaded.
    var playback: AnyPublisher<VoicePlayback?, Never> { get }

    /// Asks for the microphone the first time, then begins recording, stopping
    /// any playback first.
    func startRecording() async throws

    /// Finishes the recording and hands back the note, ready to be stored and sent.
    func stopRecording() throws -> VoiceNote

    /// Gives up on the recording and deletes it.
    func cancelRecording()

    /// The recording of `note` on the device, or nil when it is not there.
    func file(of note: VoiceNote) -> URL?

    /// Plays `file` as the note of `messageId`, carrying on from where it was
    /// paused when that note is the one already loaded.
    func play(_ messageId: Int64, file: URL) async throws

    func pausePlayback()

    /// Lets go of the microphone and the speaker.
    func release()
}
