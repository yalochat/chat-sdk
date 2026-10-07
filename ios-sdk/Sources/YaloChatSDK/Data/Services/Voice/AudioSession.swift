// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation

/// The part of `AVAudioSession` the voice services use, so tests can stay
/// off the device audio.
protocol AudioSession {
    func setCategory(
        _ category: AVAudioSession.Category,
        mode: AVAudioSession.Mode,
        options: AVAudioSession.CategoryOptions
    ) throws

    func setActive(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

extension AVAudioSession: AudioSession {}
