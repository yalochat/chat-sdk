// Copyright (c) Yalochat, Inc. All rights reserved.

import Combine
import Foundation

/// Drives the device microphone and speaker.
///
/// Two waveforms come out of one recording: the window in `recording` that
/// moves while somebody speaks, and the whole recording squeezed into the same
/// number of bars for the finished note.
@MainActor
final class VoiceRepositoryLocal: VoiceRepository {
    /// Bars in the waveform drawn while recording, and in the one sent with the
    /// note, the same number the web SDK sends.
    static let barCount: Int = 40
    static let sampleInterval: TimeInterval = 0.06
    static let progressInterval: TimeInterval = 0.1

    private let recorder: VoiceRecorderService
    private let player: VoicePlayerService
    private let directory: URL
    private let now: () -> Date
    private let sleep: @Sendable (TimeInterval) async throws -> Void
    private let recordingSubject: CurrentValueSubject<VoiceRecording?, Never> = CurrentValueSubject(nil)
    private let playbackSubject: CurrentValueSubject<VoicePlayback?, Never> = CurrentValueSubject(nil)
    private var waveform: WaveformCompressor = WaveformCompressor(barCount: barCount)
    /// Set from the moment a recording is asked for, so a second start is refused.
    private var target: URL?
    private var startedAt: Date = .distantPast
    private var sampling: Task<Void, Never>?
    private var tracking: Task<Void, Never>?

    /// - Parameter directory: Not the cache, since a recorded note is the only
    ///   copy that can be played back.
    init(
        recorder: VoiceRecorderService,
        player: VoicePlayerService,
        directory: URL,
        now: @escaping () -> Date = { Date() },
        sleep: @escaping @Sendable (TimeInterval) async throws -> Void = { seconds in
            try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        }
    ) {
        self.recorder = recorder
        self.player = player
        self.directory = directory
        self.now = now
        self.sleep = sleep
    }

    var recording: AnyPublisher<VoiceRecording?, Never> {
        recordingSubject.eraseToAnyPublisher()
    }

    var playback: AnyPublisher<VoicePlayback?, Never> {
        playbackSubject.eraseToAnyPublisher()
    }

    func startRecording() async throws {
        guard target == nil else {
            throw VoiceRecorderServiceError.alreadyRecording
        }
        stopPlayback()
        let milliseconds: Int64 = Int64(now().timeIntervalSince1970 * 1_000)
        let file: URL = directory.appendingPathComponent("voice-\(milliseconds).\(recorder.fileExtension)")
        target = file
        do {
            try await recorder.start(file)
        } catch {
            if target == file {
                target = nil
            }
            throw error
        }
        // Cancelled while the person was being asked for the microphone.
        guard target == file else {
            try? recorder.stop()
            try? FileManager.default.removeItem(at: file)
            return
        }
        startedAt = now()
        waveform = WaveformCompressor(barCount: Self.barCount)
        recordingSubject.send(VoiceRecording(elapsed: 0, amplitudes: Array(repeating: 0, count: Self.barCount)))
        sampling = Task { [weak self, sleep] in
            while !Task.isCancelled {
                do {
                    try await sleep(Self.sampleInterval)
                } catch {
                    return
                }
                guard let self, !Task.isCancelled else {
                    return
                }
                self.sample()
            }
        }
    }

    func stopRecording() throws -> VoiceNote {
        guard let file = target, recordingSubject.value != nil else {
            throw VoiceRecorderServiceError.notRecording
        }
        let duration: TimeInterval = now().timeIntervalSince(startedAt)
        stopSampling()
        do {
            try recorder.stop()
        } catch {
            try? FileManager.default.removeItem(at: file)
            throw error
        }
        let size: Int = (try? file.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0
        guard size > 0 else {
            try? FileManager.default.removeItem(at: file)
            throw VoiceRepositoryError.nothingRecorded
        }
        return VoiceNote(
            duration: duration,
            amplitudes: waveform.snapshot(),
            mimeType: recorder.mimeType,
            fileName: file.lastPathComponent,
            byteCount: Int64(size),
            localFileName: file.lastPathComponent
        )
    }

    func cancelRecording() {
        guard let file = target else {
            return
        }
        stopSampling()
        try? recorder.stop()
        try? FileManager.default.removeItem(at: file)
    }

    func file(of note: VoiceNote) -> URL? {
        guard let name = note.localFileName else {
            return nil
        }
        let file: URL = directory.appendingPathComponent(name)
        return FileManager.default.fileExists(atPath: file.path) ? file : nil
    }

    func play(_ messageId: Int64, file: URL) throws {
        if var loaded = playbackSubject.value, loaded.messageId == messageId {
            player.play()
            loaded.isPlaying = true
            playbackSubject.send(loaded)
            startTracking()
            return
        }
        stopPlayback()
        try player.load(file) { [weak self] in
            self?.finish(messageId)
        }
        player.play()
        playbackSubject.send(VoicePlayback(messageId: messageId, position: 0, duration: player.duration, isPlaying: true))
        startTracking()
    }

    func pausePlayback() {
        guard var loaded = playbackSubject.value else {
            return
        }
        stopTracking()
        player.pause()
        loaded.position = player.position
        loaded.isPlaying = false
        playbackSubject.send(loaded)
    }

    func release() {
        cancelRecording()
        stopPlayback()
    }

    /// Folds one reading of the microphone into both waveforms.
    private func sample() {
        guard let window = recordingSubject.value else {
            return
        }
        let level: Float = recorder.amplitude()
        waveform.push(level)
        recordingSubject.send(VoiceRecording(
            elapsed: now().timeIntervalSince(startedAt),
            amplitudes: Array(window.amplitudes.dropFirst()) + [level]
        ))
    }

    /// Follows the playhead, so the waveform fills as the note is listened to.
    private func startTracking() {
        tracking?.cancel()
        tracking = Task { [weak self, sleep] in
            while !Task.isCancelled {
                do {
                    try await sleep(Self.progressInterval)
                } catch {
                    return
                }
                guard let self, !Task.isCancelled, var loaded = self.playbackSubject.value else {
                    return
                }
                loaded.position = self.player.position
                self.playbackSubject.send(loaded)
            }
        }
    }

    private func stopTracking() {
        tracking?.cancel()
        tracking = nil
    }

    /// Left loaded and rewound, so playing again starts over without a download.
    private func finish(_ messageId: Int64) {
        stopTracking()
        guard var loaded = playbackSubject.value, loaded.messageId == messageId else {
            return
        }
        loaded.position = 0
        loaded.isPlaying = false
        playbackSubject.send(loaded)
    }

    private func stopPlayback() {
        stopTracking()
        guard playbackSubject.value != nil else {
            return
        }
        player.stop()
        playbackSubject.send(nil)
    }

    private func stopSampling() {
        sampling?.cancel()
        sampling = nil
        target = nil
        recordingSubject.send(nil)
    }
}
