// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Everything one conversation needs, built the first time it is asked for.
@MainActor
final class ChatDependencies {
    private let baseURL: URL
    private let cacheDirectory: URL
    private let session: URLSession

    init(
        baseURL: URL = YaloAPI.baseURL,
        cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.cacheDirectory = cacheDirectory
        self.session = session
    }

    lazy var media: YaloMediaService = YaloMediaRemoteService(
        baseURL: baseURL,
        cacheDirectory: cacheDirectory.appendingPathComponent("yalo-chat-media", isDirectory: true),
        session: session
    )
}
