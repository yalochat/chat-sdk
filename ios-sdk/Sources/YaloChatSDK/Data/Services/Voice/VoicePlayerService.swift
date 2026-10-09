// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

enum VoicePlayerServiceError: Error, Equatable {
    /// The file is missing, truncated or in a format the device will not decode.
    case unplayable
}

/// Plays one voice note at a time through the device.
@MainActor
protocol VoicePlayerService {
    /// How far into the loaded note playback has got, or zero when none is loaded.
    var position: TimeInterval { get }

    /// How long the loaded note runs, or zero when none is loaded.
    var duration: TimeInterval { get }

    /// Loads `file`, ready to play from the start, and lets go of whatever was
    /// loaded before. `onFinished` runs when playback reaches the end, never
    /// when it is paused or replaced.
    func load(_ file: URL, onFinished: @escaping @MainActor () -> Void) throws

    /// Plays from wherever the loaded note is, once the audio has switched
    /// over. Nothing loaded, nothing happens.
    func play() async

    func pause()

    /// Lets go of the device, whether or not anything was loaded.
    func stop()
}
