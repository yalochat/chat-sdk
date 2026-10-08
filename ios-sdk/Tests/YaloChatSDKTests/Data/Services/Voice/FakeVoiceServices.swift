// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
@testable import YaloChatSDK

/// Stands in for the microphone. A finished recording holds `bytes`.
@MainActor
final class FakeVoiceRecorder: VoiceRecorderService {
    let mimeType: String = "audio/mp4"
    let fileExtension: String = "m4a"
    var level: Float = 0.5
    var bytes: Data = Data("voice".utf8)
    var startError: Error?
    var stopError: Error?
    /// Runs while the person is being asked for the microphone.
    var whileAsking: @MainActor () async -> Void = {}
    private(set) var target: URL?

    func start(_ target: URL) async throws {
        await whileAsking()
        if let startError {
            throw startError
        }
        guard self.target == nil else {
            throw VoiceRecorderServiceError.alreadyRecording
        }
        try FileManager.default.createDirectory(
            at: target.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        self.target = target
    }

    func amplitude() -> Float {
        level
    }

    func stop() throws {
        guard let target else {
            throw VoiceRecorderServiceError.notRecording
        }
        self.target = nil
        if let stopError {
            throw stopError
        }
        try bytes.write(to: target)
    }
}

/// Stands in for the speaker. `finish()` plays the loaded note to its end.
@MainActor
final class FakeVoicePlayer: VoicePlayerService {
    var position: TimeInterval = 0
    var duration: TimeInterval = 0
    var loadError: Error?
    private(set) var loads: [URL] = []
    private(set) var isPlaying: Bool = false
    private var onFinished: (@MainActor () -> Void)?

    var loaded: URL? {
        onFinished == nil ? nil : loads.last
    }

    func load(_ file: URL, onFinished: @escaping @MainActor () -> Void) throws {
        if let loadError {
            throw loadError
        }
        loads.append(file)
        duration = 3
        self.onFinished = onFinished
    }

    func play() {
        isPlaying = loaded != nil
    }

    func pause() {
        isPlaying = false
    }

    func stop() {
        isPlaying = false
        onFinished = nil
    }

    func finish() {
        isPlaying = false
        onFinished?()
    }
}
