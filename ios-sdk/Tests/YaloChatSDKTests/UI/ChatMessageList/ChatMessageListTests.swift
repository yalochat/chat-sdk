// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatMessageListTests {
    @Test func messageListRendersUserAndAgentMessages() {
        let messages: [ChatMessage] = [
            ChatMessage(role: .agent, type: .text, timestamp: Date(), id: 1, content: "**Hi**\n\n- Orders"),
            ChatMessage(role: .user, type: .text, timestamp: Date(), id: 2, content: "Hello"),
        ]
        #expect(renders(ChatMessageList(messages: messages)))
    }
}
