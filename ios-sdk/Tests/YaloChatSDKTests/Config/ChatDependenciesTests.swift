// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatDependenciesTests {
    private let config: YaloChatClientConfig = YaloChatClientConfig(
        channelId: "channel-1",
        organizationId: "org-1",
        channelName: "Yalo"
    )

    @Test func mediaIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.mediaService as AnyObject === dependencies.mediaService as AnyObject)
        #expect(dependencies.media === dependencies.media)
    }

    @Test func mediaTalksToTheBaseURLAndCachesUnderTheCacheDirectory() async throws {
        let server: StubServer = StubServer(status: 200, body: Data("voice bytes".utf8))
        let cacheDirectory: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let dependencies: ChatDependencies = ChatDependencies(
            config: config,
            baseURL: server.baseURL,
            cacheDirectory: cacheDirectory,
            session: server.session
        )

        let file: URL = try await dependencies.mediaService.download(server.baseURL.appendingPathComponent("a.ogg").absoluteString)

        #expect(file.deletingLastPathComponent().lastPathComponent == "yalo-chat-media")
        #expect(file.path.hasPrefix(cacheDirectory.path))
    }

    @Test func authIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.auth as AnyObject === dependencies.auth as AnyObject)
    }

    @Test func authTalksToTheBaseURLForTheChannelAndUser() async throws {
        let server: StubServer = StubServer(body: Data("""
        {"access_token": "access", "refresh_token": "refresh", "expires_in": 60}
        """.utf8))
        let dependencies: ChatDependencies = ChatDependencies(
            config: YaloChatClientConfig(
                channelId: "channel-1",
                organizationId: "org-1",
                channelName: "Yalo",
                userId: "user-1"
            ),
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

    @Test func imagesIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.images as AnyObject === dependencies.images as AnyObject)
    }

    @Test func imagesAreCopiedUnderTheImagesDirectory() async throws {
        let imagesDirectory: URL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let picked: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        try Data("picture bytes".utf8).write(to: picked)
        let dependencies: ChatDependencies = ChatDependencies(
            config: config,
            imagesDirectory: imagesDirectory
        )

        let content: MediaContent = try await dependencies.images.content(try #require(NSItemProvider(contentsOf: picked)))

        #expect(content.fileURL.standardizedFileURL.path.hasPrefix(imagesDirectory.standardizedFileURL.path))
    }

    @Test func voiceRecorderIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.voiceRecorder as AnyObject === dependencies.voiceRecorder as AnyObject)
    }

    @Test func voicePlayerIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.voicePlayer as AnyObject === dependencies.voicePlayer as AnyObject)
    }

    @Test func voiceIsBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.voice === dependencies.voice)
    }

    @Test func tokensAreBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.tokens === dependencies.tokens)
    }

    @Test func tokensAreIssuedByTheAuthService() async throws {
        let server: StubServer = StubServer(body: Data("""
        {"access_token": "access", "refresh_token": "refresh", "expires_in": 60}
        """.utf8))
        let dependencies: ChatDependencies = ChatDependencies(config: config, baseURL: server.baseURL, session: server.session)

        let token: String = try await dependencies.tokens.token()

        #expect(token == "access")
    }

    @Test func yaloMessagesAreBuiltOnceAndShared() {
        let dependencies: ChatDependencies = ChatDependencies(config: config)

        #expect(dependencies.yaloMessageService as AnyObject === dependencies.yaloMessageService as AnyObject)
        #expect(dependencies.yaloMessages === dependencies.yaloMessages)
    }

    @Test func chatViewModelsShareTheConversationsStorage() async throws {
        // Refuses every token, so no socket is ever opened.
        let server: StubServer = StubServer(status: 500)
        let dependencies: ChatDependencies = ChatDependencies(
            config: config,
            baseURL: server.baseURL,
            databaseURL: nil,
            session: server.session
        )
        _ = try await dependencies.chatMessages.insert(
            ChatMessage(role: .agent, type: .text, timestamp: Date(), wiId: "wi-1", content: "Hi"),
            sessionId: config.sessionId
        )
        let viewModel: ChatViewModel = dependencies.chatViewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.map(\.content) == ["Hi"] })
        running.cancel()
    }
}
