// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatDependenciesTests {
    @Test func mediaIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies()

        #expect(dependencies.media as AnyObject === dependencies.media as AnyObject)
    }

    @Test func mediaTalksToTheBaseURLAndCachesUnderTheCacheDirectory() async throws {
        let server: StubServer = StubServer(status: 200, body: Data("voice bytes".utf8))
        let cacheDirectory: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let dependencies: ChatDependencies = ChatDependencies(
            baseURL: server.baseURL,
            cacheDirectory: cacheDirectory,
            session: server.session
        )

        let file: URL = try await dependencies.media.download(server.baseURL.appendingPathComponent("a.ogg").absoluteString)

        #expect(file.deletingLastPathComponent().lastPathComponent == "yalo-chat-media")
        #expect(file.path.hasPrefix(cacheDirectory.path))
    }
}
