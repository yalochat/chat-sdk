// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatDependenciesTests {
    @Test func mediaIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(channelId: "channel-1", organizationId: "org-1")

        #expect(dependencies.media as AnyObject === dependencies.media as AnyObject)
    }

    @Test func mediaTalksToTheBaseURLAndCachesUnderTheCacheDirectory() async throws {
        let server: StubServer = StubServer(status: 200, body: Data("voice bytes".utf8))
        let cacheDirectory: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let dependencies: ChatDependencies = ChatDependencies(
            channelId: "channel-1",
            organizationId: "org-1",
            baseURL: server.baseURL,
            cacheDirectory: cacheDirectory,
            session: server.session
        )

        let file: URL = try await dependencies.media.download(server.baseURL.appendingPathComponent("a.ogg").absoluteString)

        #expect(file.deletingLastPathComponent().lastPathComponent == "yalo-chat-media")
        #expect(file.path.hasPrefix(cacheDirectory.path))
    }

    @Test func authIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(channelId: "channel-1", organizationId: "org-1")

        #expect(dependencies.auth as AnyObject === dependencies.auth as AnyObject)
    }

    @Test func authTalksToTheBaseURLForTheChannelAndUser() async throws {
        let server: StubServer = StubServer(body: Data("""
        {"access_token": "access", "refresh_token": "refresh", "expires_in": 60}
        """.utf8))
        let dependencies: ChatDependencies = ChatDependencies(
            channelId: "channel-1",
            organizationId: "org-1",
            authUserId: "user-1",
            baseURL: server.baseURL,
            session: server.session
        )

        _ = try await dependencies.auth.authenticate()

        let sent: RecordedRequest = try #require(server.requests.first)
        let body: [String: Any] = try #require(try JSONSerialization.jsonObject(with: sent.body) as? [String: Any])
        #expect(sent.request.url?.path == "/v1/channels/auth")
        #expect(body["channel_id"] as? String == "channel-1")
        #expect(body["organization_id"] as? String == "org-1")
        #expect(body["user_id"] as? String == "user-1")
    }
}
