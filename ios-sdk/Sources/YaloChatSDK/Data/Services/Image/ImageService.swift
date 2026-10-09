// Copyright (c) Yalochat, Inc. All rights reserved.

import UIKit

enum ImageServiceError: Error, Equatable {
    /// What was picked holds no picture.
    case notAnImage
    /// The device would not hand the picture over.
    case unreadable
}

/// Reads whatever the person picked out of the photo library.
protocol ImageService: Sendable {
    /// Copies the picture `picked` holds and describes the copy. The picker
    /// deletes its own file once it is handed over, so the copy is what stays
    /// readable for the upload and for the chat to show.
    func content(_ picked: NSItemProvider) async throws -> MediaContent

    /// The copy `picture` names on the device, or nil once it is gone.
    func file(of picture: ImageAttachment) -> URL?

    /// Reads `file` as a picture no bigger than a bubble needs, or nil when it
    /// is not one. Runs off the main thread.
    func image(at file: URL) async -> UIImage?
}
