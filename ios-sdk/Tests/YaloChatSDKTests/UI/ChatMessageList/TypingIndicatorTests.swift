// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

@MainActor
struct TypingIndicatorTests {
    @Test func typingIndicatorRenders() {
        #expect(renders(TypingIndicator()))
    }

    @Test func typingTextRenders() {
        #expect(renders(TypingText()))
    }

    @Test func typingTextRendersTheTextTheAppGives() {
        #expect(renders(TypingText(text: "Thinking")))
    }
}
