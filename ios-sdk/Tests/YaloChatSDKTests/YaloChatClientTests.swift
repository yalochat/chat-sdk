// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct YaloChatClientTests {
    private let client: YaloChatClient = YaloChatClient(
        config: YaloChatClientConfig(channelId: "channel", organizationId: "organization", channelName: "Support")
    )

    @Test func handsBackTheHandlerRegisteredForACommand() async throws {
        client.registerCommand("getStore") { payload in "store \(payload)" }

        let handler: CommandHandler = try #require(client.commandHandler(for: "getStore"))
        #expect(try await handler("42") == "store 42")
    }

    @Test func keepsTheLatestHandlerForACommandRegisteredTwice() async throws {
        client.registerCommand("getStore") { _ in "first" }
        client.registerCommand("getStore") { _ in "second" }

        let handler: CommandHandler = try #require(client.commandHandler(for: "getStore"))
        #expect(try await handler("") == "second")
    }

    @Test func hasNoHandlerForACommandNeverRegistered() {
        #expect(client.commandHandler(for: "getStore") == nil)
    }

    private let storage: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: nil)
    private let tokenStore: FakeTokenStore = FakeTokenStore()
    private let resets: ChatResets = ChatResets()
    private let files: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-client-tests-\(UUID().uuidString)", isDirectory: true)

    private func clearingClient(sessionMode: SessionMode = .shared) -> YaloChatClient {
        YaloChatClient(
            config: YaloChatClientConfig(
                channelId: "channel",
                organizationId: "organization",
                channelName: "Support",
                sessionMode: sessionMode
            ),
            chatMessages: storage,
            tokenStore: tokenStore,
            messageFiles: [files],
            resets: resets
        )
    }

    private func message(_ content: String) -> ChatMessage {
        ChatMessage(role: .agent, type: .text, timestamp: Date(), content: content)
    }

    private func token() -> AuthToken {
        AuthToken(accessToken: "access", refreshToken: "refresh", expiresAt: .distantFuture)
    }

    private func storeEverything() async throws {
        _ = try await storage.insert(message("mine"), sessionId: "session-1")
        _ = try await storage.insert(message("elsewhere"), sessionId: "other")
        try tokenStore.save(token(), sessionId: "session-1", ephemeral: false)
        try FileManager.default.createDirectory(at: files, withIntermediateDirectories: true)
    }

    private func storedMessages() async throws -> Int {
        try await storage.messages(sessionId: "session-1", limit: 10).count
            + storage.messages(sessionId: "other", limit: 10).count
    }

    @Test(arguments: [SessionMode.shared, .ephemeral])
    func clearingDeletesEveryStoredMessageAndKeepsTheTokens(sessionMode: SessionMode) async throws {
        try await storeEverything()

        await clearingClient(sessionMode: sessionMode).clearMessages()

        #expect(try await storedMessages() == 0)
        #expect(!FileManager.default.fileExists(atPath: files.path))
        #expect(tokenStore.stored("session-1") != nil)
    }

    @Test func loggingOutDeletesEveryMessageAndEveryToken() async throws {
        try await storeEverything()
        try tokenStore.save(token(), sessionId: "other", ephemeral: true)

        await clearingClient().logout()

        #expect(try await storedMessages() == 0)
        #expect(!FileManager.default.fileExists(atPath: files.path))
        #expect(tokenStore.stored("session-1") == nil)
        #expect(tokenStore.stored("other") == nil)
    }

    @Test func loggingOutDeletesTheMessagesWhenTheTokensCannotBeForgotten() async throws {
        try await storeEverything()
        tokenStore.fail(with: TokenStoreServiceError.keychainFailed(status: -1))
        var requests: AsyncStream<ChatReset>.Iterator = clearingClient().clearRequests().makeAsyncIterator()

        await clearingClient().logout()

        #expect(try await storedMessages() == 0)
        #expect(await requests.next() == .logout)
    }

    @Test func clearingTellsEveryChatListeningWhicheverClientAsked() async {
        var first: AsyncStream<ChatReset>.Iterator = clearingClient().clearRequests().makeAsyncIterator()
        var second: AsyncStream<ChatReset>.Iterator = clearingClient().clearRequests().makeAsyncIterator()

        await clearingClient().clearMessages()

        #expect(await first.next() == .messages)
        #expect(await second.next() == .messages)
    }

    @Test func loggingOutTellsEveryChatListening() async {
        var requests: AsyncStream<ChatReset>.Iterator = clearingClient().clearRequests().makeAsyncIterator()

        await clearingClient().logout()

        #expect(await requests.next() == .logout)
    }

    @Test func clearingWhenStorageFailsStillTellsTheChats() async throws {
        let unreadable: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: unreadable, withIntermediateDirectories: true)
        let client: YaloChatClient = YaloChatClient(
            config: YaloChatClientConfig(channelId: "channel", organizationId: "organization", channelName: "Support"),
            chatMessages: ChatMessageDatabaseService(fileURL: unreadable),
            resets: resets
        )
        var requests: AsyncStream<ChatReset>.Iterator = client.clearRequests().makeAsyncIterator()

        await client.clearMessages()

        #expect(await requests.next() == .messages)
    }
}
