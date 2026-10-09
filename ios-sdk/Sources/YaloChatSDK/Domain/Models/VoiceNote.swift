// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The recording a voice message carries.
///
/// `mediaURL` is the id the upload answered with for a note the person
/// recorded, and an address to download from for one the channel sent.
/// `localFileName` names the recording on the device, kept as a name rather
/// than a path because the app's folder moves when the app is updated.
///
/// `amplitudes` run from zero to one and span the whole recording.
struct VoiceNote: Equatable, Sendable, Codable {
    var duration: TimeInterval
    var amplitudes: [Float] = []
    var mediaURL: String = ""
    var mimeType: String = ""
    var fileName: String = ""
    var byteCount: Int64 = 0
    var localFileName: String?
}
