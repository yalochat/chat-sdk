// Copyright (c) Yalochat, Inc. All rights reserved.

import UIKit

enum ImageServiceError: Error, Equatable {
    /// What was picked holds no picture.
    case notAnImage
    /// The device would not hand the picture over.
    case unreadable
}

/// A video ready to play: `file` is what the player opens, `poster` its first
/// frame and `duration` its length in seconds, zero when unknown.
final class VideoPreview: Sendable {
    let file: URL
    let poster: UIImage
    let duration: TimeInterval

    init(file: URL, poster: UIImage, duration: TimeInterval) {
        self.file = file
        self.poster = poster
        self.duration = duration
    }
}

/// Reads whatever the person picked out of the photo library, and the
/// pictures and videos the chat shows.
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

    /// Reads the downloaded `file` of `video`, or nil when it cannot be played.
    /// Runs off the main thread.
    func preview(of video: VideoAttachment, at file: URL) async -> VideoPreview?
}
