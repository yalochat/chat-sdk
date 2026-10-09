// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation

/// The part of `AVAudioSession` the voice services use, so tests can stay
/// off the device audio.
protocol AudioSession: Sendable {
    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

extension AVAudioSession: AudioSession {}

/// Switching the session waits on the system, which can freeze the UI, so it
/// happens here. Serial, so a deactivation never lands after a later activation.
/// `AVAudioRecorder.record()` and `AVAudioPlayer.prepareToPlay()` switch it
/// too, so they run here as well.
private let switching: DispatchQueue = DispatchQueue(label: "ai.yalo.chat.audio-session")

extension AudioSession {
    /// Runs `then` once the session is active, before anything queued after it.
    func activate(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions,
        then: @escaping @Sendable () throws -> Void = {}
    ) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            switching.async {
                do {
                    try setCategory(category, mode: mode, options: options)
                    try setActive(true, options: [])
                    try then()
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Lets whatever the session interrupted, like music, carry on. Nothing waits for it.
    func deactivate() {
        switching.async {
            try? setActive(false, options: .notifyOthersOnDeactivation)
        }
    }
}
