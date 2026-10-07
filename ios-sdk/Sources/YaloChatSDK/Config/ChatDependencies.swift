// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Everything one conversation needs, built the first time it is asked for.
@MainActor
final class ChatDependencies {
    private let channelId: String
    private let organizationId: String
    private let authUserId: String?
    private let baseURL: URL
    private let cacheDirectory: URL
    private let session: URLSession

    init(
        channelId: String,
        organizationId: String,
        authUserId: String? = nil,
        baseURL: URL = YaloAPI.baseURL,
        cacheDirectory: URL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0],
        session: URLSession = .shared
    ) {
        self.channelId = channelId
        self.organizationId = organizationId
        self.authUserId = authUserId
        self.baseURL = baseURL
        self.cacheDirectory = cacheDirectory
        self.session = session
    }

    lazy var media: YaloMediaService = YaloMediaRemoteService(
        baseURL: baseURL,
        cacheDirectory: cacheDirectory.appendingPathComponent("yalo-chat-media", isDirectory: true),
        session: session
    )

    lazy var auth: YaloMessageAuthService = YaloMessageAuthRemoteService(
        channelId: channelId,
        organizationId: organizationId,
        authUserId: authUserId,
        baseURL: baseURL,
        session: session
    )
}
