// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

enum VoiceRecorderServiceError: Error, Equatable {
    /// The person did not let the app use the microphone.
    case permissionDenied
    case alreadyRecording
    case notRecording
    /// The microphone is busy or missing, or the file cannot be written.
    case unavailable
}

/// The device microphone, as much of it as a voice note needs.
@MainActor
protocol VoiceRecorderService {
    /// What the recording is written as, so an upload can say what it is sending.
    var mimeType: String { get }

    /// The file extension that goes with `mimeType`, without the dot.
    var fileExtension: String { get }

    /// Asks for the microphone the first time, then begins writing a recording
    /// to `target`, replacing whatever was there.
    func start(_ target: URL) async throws

    /// The loudest sound heard since this was last asked, from zero to one.
    /// Reading it is what moves the window along, so ask at the rate the
    /// waveform is drawn at.
    func amplitude() -> Float

    /// Finishes the recording and lets go of the microphone. The file is left
    /// in place, for the caller to send or delete.
    func stop() throws
}
