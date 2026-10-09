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

    @Test func imagesAreCopiedUnderTheStorageDirectory() async throws {
        let storageDirectory: URL = Self.temporaryDirectory()
        let dependencies: ChatDependencies = ChatDependencies(config: config, storageDirectory: storageDirectory)

        let content: MediaContent = try await dependencies.images.content(try Self.pickedPicture())

        #expect(content.fileURL.deletingLastPathComponent().standardizedFileURL
            == storageDirectory.appendingPathComponent("images").standardizedFileURL)
    }

    @Test func anEphemeralConversationKeepsItsImagesInItsOwnFolder() async throws {
        let storageDirectory: URL = Self.temporaryDirectory()
        let dependencies: ChatDependencies = ChatDependencies(
            config: YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo", sessionMode: .ephemeral),
            storageDirectory: storageDirectory
        )

        let content: MediaContent = try await dependencies.images.content(try Self.pickedPicture())

        let expected: URL = storageDirectory
            .appendingPathComponent("ephemeral/\(dependencies.chatSession.id)/images")
        #expect(content.fileURL.deletingLastPathComponent().standardizedFileURL == expected.standardizedFileURL)
    }

    @Test func everyEphemeralChatIsItsOwnConversation() {
        let ephemeral: YaloChatClientConfig = YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            sessionMode: .ephemeral
        )

        #expect(ChatDependencies(config: ephemeral).chatSession != ChatDependencies(config: ephemeral).chatSession)
        #expect(ChatDependencies(config: config).chatSession == ChatDependencies(config: config).chatSession)
    }

    @Test func authIsToldTheSessionsUser() async throws {
        let server: StubServer = StubServer(body: Data("""
        {"access_token": "access", "refresh_token": "refresh", "expires_in": 60}
        """.utf8))
        let dependencies: ChatDependencies = ChatDependencies(
            config: YaloChatClientConfig(
                channelId: "channel-1",
                organizationId: "org-1",
                channelName: "Yalo",
                userId: "user-1",
                openContext: ["sku": "37549996"],
                sessionMode: .perContext
            ),
            baseURL: server.baseURL,
            session: server.session
        )

        _ = try await dependencies.auth.authenticate()

        let sent: RecordedRequest = try #require(server.requests.first)
        let body: [String: Any] = try #require(try JSONSerialization.jsonObject(with: sent.body) as? [String: Any])
        #expect(body["user_id"] as? String == dependencies.chatSession.authUserId)
        #expect(dependencies.chatSession.authUserId != "user-1")
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
        let dependencies: ChatDependencies = ChatDependencies(
            config: config,
            baseURL: server.baseURL,
            session: server.session,
            tokenStore: FakeTokenStore()
        )

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
            storageDirectory: Self.temporaryDirectory(),
            session: server.session,
            tokenStore: FakeTokenStore()
        )
        _ = try await dependencies.chatMessages.insert(
            ChatMessage(role: .agent, type: .text, timestamp: Date(), wiId: "wi-1", content: "Hi"),
            sessionId: dependencies.chatSession.id
        )
        let viewModel: ChatViewModel = dependencies.chatViewModel()

        let running: Task<Void, Never> = Task {
            await viewModel.start()
        }

        #expect(await eventually { viewModel.messages.map(\.content) == ["Hi"] })
        running.cancel()
    }

    private static func temporaryDirectory() -> URL {
        FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    private static func pickedPicture() throws -> NSItemProvider {
        let picked: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).jpg")
        try Data("picture bytes".utf8).write(to: picked)
        return try #require(NSItemProvider(contentsOf: picked))
    }
}
