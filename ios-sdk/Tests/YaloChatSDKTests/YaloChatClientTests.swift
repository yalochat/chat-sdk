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

    private func clearingClient(sessionMode: SessionMode = .shared) -> (YaloChatClient, ChatMessageDatabaseService, String) {
        let config: YaloChatClientConfig = YaloChatClientConfig(
            channelId: "channel",
            organizationId: "organization",
            channelName: "Support",
            sessionMode: sessionMode
        )
        let storage: ChatMessageDatabaseService = ChatMessageDatabaseService(fileURL: nil)
        return (YaloChatClient(config: config, chatMessages: storage), storage, ChatSession(config: config).id)
    }

    private func message(_ content: String) -> ChatMessage {
        ChatMessage(role: .agent, type: .text, timestamp: Date(), content: content)
    }

    @Test func clearingDeletesTheStoredMessagesOfTheConversation() async throws {
        let (client, storage, sessionId): (YaloChatClient, ChatMessageDatabaseService, String) = clearingClient()
        _ = try await storage.insert(message("mine"), sessionId: sessionId)
        _ = try await storage.insert(message("elsewhere"), sessionId: "other")

        await client.clearMessages()

        #expect(try await storage.messages(sessionId: sessionId, limit: 10).isEmpty)
        #expect(try await storage.messages(sessionId: "other", limit: 10).count == 1)
    }

    @Test func clearingTellsEveryChatListening() async {
        let (client, _, _): (YaloChatClient, ChatMessageDatabaseService, String) = clearingClient()
        var first: AsyncStream<Void>.Iterator = client.clearRequests().makeAsyncIterator()
        var second: AsyncStream<Void>.Iterator = client.clearRequests().makeAsyncIterator()

        await client.clearMessages()

        #expect(await first.next() != nil)
        #expect(await second.next() != nil)
    }

    @Test func clearingAnEphemeralConversationLeavesItToItsChat() async throws {
        let (client, storage, _): (YaloChatClient, ChatMessageDatabaseService, String) = clearingClient(sessionMode: .ephemeral)
        var requests: AsyncStream<Void>.Iterator = client.clearRequests().makeAsyncIterator()
        _ = try await storage.insert(message("elsewhere"), sessionId: "other")

        await client.clearMessages()

        #expect(await requests.next() != nil)
        #expect(try await storage.messages(sessionId: "other", limit: 10).count == 1)
    }
}
