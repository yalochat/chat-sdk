// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
@testable import YaloChatSDK

/// Stands in for the device audio session and remembers what it was told.
/// Locked, since the session is switched off the main thread.
final class StubAudioSession: AudioSession, @unchecked Sendable {
    private struct State {
        var failure: Error?
        var category: AVAudioSession.Category?
        var mode: AVAudioSession.Mode?
        var isActive: Bool = false
        var deactivationOptions: AVAudioSession.SetActiveOptions = []
        var isActivating: Bool = false
    }

    private let lock: NSLock = NSLock()
    private var state: State = State()
    /// When set, an activation waits for it to be signalled.
    let gate: DispatchSemaphore?

    init(gate: DispatchSemaphore? = nil) {
        self.gate = gate
    }

    var isActivating: Bool {
        lock.withLock { state.isActivating }
    }

    var failure: Error? {
        get {
            lock.withLock { state.failure }
        }
        set {
            lock.withLock { state.failure = newValue }
        }
    }

    var category: AVAudioSession.Category? {
        lock.withLock { state.category }
    }

    var mode: AVAudioSession.Mode? {
        lock.withLock { state.mode }
    }

    var isActive: Bool {
        lock.withLock { state.isActive }
    }

    var deactivationOptions: AVAudioSession.SetActiveOptions {
        lock.withLock { state.deactivationOptions }
    }

    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws {
        try lock.withLock {
            if let failure = state.failure {
                throw failure
            }
            state.category = category
            state.mode = mode
        }
    }

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        if active, let gate {
            lock.withLock { state.isActivating = true }
            gate.wait()
        }
        try lock.withLock {
            if let failure = state.failure, active {
                throw failure
            }
            state.isActive = active
            if !active {
                state.deactivationOptions = options
            }
        }
    }
}
