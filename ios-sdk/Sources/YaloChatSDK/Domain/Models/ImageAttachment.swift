// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The picture an image message carries.
///
/// `mediaURL` is the id the upload answered with for a picture the person
/// picked, and an address to download from for one the channel sent.
/// `localFileName` names the copy on the device, kept as a name rather than a
/// path because the app's folder moves when the app is updated.
struct ImageAttachment: Equatable, Sendable, Codable {
    var mediaURL: String = ""
    var mimeType: String = ""
    var fileName: String = ""
    var byteCount: Int64 = 0
    var localFileName: String?
}
