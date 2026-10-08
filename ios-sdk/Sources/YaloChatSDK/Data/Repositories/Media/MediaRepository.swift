// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// The files a conversation carries, on their way to the backend and back.
///
/// A token can be refused before it was due to run out, so a refusal is
/// answered once with a new token. A second one is reported.
final class MediaRepository: Sendable {
    private let service: YaloMediaService
    private let tokens: TokenRepository

    init(service: YaloMediaService, tokens: TokenRepository) {
        self.service = service
        self.tokens = tokens
    }

    func upload(_ content: MediaContent) async throws -> Media {
        do {
            return try await service.upload(content, token: try await tokens.token())
        } catch MediaServiceError.staleToken {
            await tokens.invalidate()
            return try await service.upload(content, token: try await tokens.token())
        }
    }

    /// Asking twice for the same `url` costs one download.
    func download(_ url: String) async throws -> URL {
        try await service.download(url)
    }
}
