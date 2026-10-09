// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
@testable import YaloChatSDK

/// Answers uploads with `media-1`, `media-2`... and downloads with `downloadable`.
actor FakeYaloMediaService: YaloMediaService {
    private(set) var uploads: [MediaContent] = []
    private(set) var uploadTokens: [String] = []
    private(set) var downloads: [String] = []
    private var uploadErrors: [Error] = []
    private var downloadable: URL?

    func failUploads(with errors: [Error]) {
        uploadErrors = errors
    }

    func serveDownloads(from file: URL) {
        downloadable = file
    }

    func upload(_ content: MediaContent, token: String) async throws -> Media {
        uploads.append(content)
        uploadTokens.append(token)
        if !uploadErrors.isEmpty {
            throw uploadErrors.removeFirst()
        }
        return Media(id: "media-\(uploads.count)", signedURL: "", originalName: content.fileName, type: .voice)
    }

    func download(_ url: String) async throws -> URL {
        downloads.append(url)
        guard let downloadable else {
            throw MediaServiceError.downloadFailed(status: 404)
        }
        return downloadable
    }
}

/// Issues `access-1`, `access-2`... and never refreshes.
actor CountingAuthService: YaloMessageAuthService {
    private(set) var issued: Int = 0

    func authenticate() async throws -> AuthToken {
        issued += 1
        return AuthToken(accessToken: "access-\(issued)", refreshToken: "", expiresAt: .distantFuture)
    }

    func refresh(_ refreshToken: String) async throws -> AuthToken {
        throw AuthServiceError.refreshFailed(status: 401)
    }
}
