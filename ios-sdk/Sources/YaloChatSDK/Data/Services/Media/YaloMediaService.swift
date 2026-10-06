// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// A local file on its way to the backend. It is read from disk on every
/// upload, so a retry sends the whole file again.
struct MediaContent: Equatable, Sendable {
    let fileURL: URL
    let fileName: String
    let mimeType: String
}

/// `signedURL` expires, so it is worth following rather than keeping.
struct Media: Equatable, Sendable {
    let id: String
    let signedURL: String
    let originalName: String
    let type: MessageType
}

enum MediaServiceError: Error, Equatable {
    /// The backend refused the token. The only failure worth retrying with a new token.
    case staleToken
    case uploadFailed(status: Int)
    case downloadFailed(status: Int)
    case invalidAddress(String)
    case unreadableResponse
}

/// Moves the files a conversation carries to the backend and back.
protocol YaloMediaService: Sendable {
    /// Sends `content` under `token`, once. Retrying is up to the caller.
    func upload(_ content: MediaContent, token: String) async throws -> Media

    /// Fetches `url` into the cache and returns the local file. Asking twice costs one download.
    func download(_ url: String) async throws -> URL
}
