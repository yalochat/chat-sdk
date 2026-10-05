// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

@MainActor
struct ChatMessageListTests {
    @Test func messageListRendersUserAndAgentMessages() {
        let messages: [ChatMessage] = [
            ChatMessage(id: "1", role: .agent, text: "Hi"),
            ChatMessage(id: "2", role: .user, text: "Hello"),
        ]
        #expect(renders(ChatMessageList(messages: messages)))
    }
}
