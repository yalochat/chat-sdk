// Copyright (c) Yalochat, Inc. All rights reserved.

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
}
