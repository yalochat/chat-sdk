// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

struct MessageButtonTests {
    @Test func splitsTheButtonsIntoQuickRepliesAndActions() {
        let message: ChatMessage = ChatMessage(role: .agent, type: .text, timestamp: Date(), buttons: [
            MessageButton(text: "Yes"),
            MessageButton(text: "Menu", kind: .postback),
            MessageButton(text: "Site", kind: .link, url: "https://yalo.ai"),
            MessageButton(text: "No"),
        ])

        #expect(message.quickReplies.map(\.text) == ["Yes", "No"])
        #expect(message.actions.map(\.text) == ["Menu", "Site"])
    }

    @Test func aKindThisVersionDoesNotKnowReadsBackAsAReply() throws {
        let stored: Data = Data(#"[{"text":"Later","kind":"carousel"}]"#.utf8)

        #expect(try JSONDecoder().decode([MessageButton].self, from: stored) == [MessageButton(text: "Later")])
    }
}
