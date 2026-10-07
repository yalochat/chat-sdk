// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
@testable import YaloChatSDK

/// Stands in for the device audio session and remembers what it was told.
final class StubAudioSession: AudioSession {
    var failure: Error?
    private(set) var category: AVAudioSession.Category?
    private(set) var mode: AVAudioSession.Mode?
    private(set) var isActive: Bool = false
    private(set) var deactivationOptions: AVAudioSession.SetActiveOptions = []

    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws {
        if let failure {
            throw failure
        }
        self.category = category
        self.mode = mode
    }

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws {
        if let failure, active {
            throw failure
        }
        isActive = active
        if !active {
            deactivationOptions = options
        }
    }
}
