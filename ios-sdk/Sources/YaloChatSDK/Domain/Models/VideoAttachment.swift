// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The video a video message carries. `mediaURL` is an address to download
/// from, and `duration` is in seconds, zero when the channel did not say.
struct VideoAttachment: Equatable, Sendable, Codable {
    var mediaURL: String = ""
    var mimeType: String = ""
    var fileName: String = ""
    var byteCount: Int64 = 0
    var duration: TimeInterval = 0
}
