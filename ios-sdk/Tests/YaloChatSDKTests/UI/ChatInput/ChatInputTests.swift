// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

@MainActor
struct ChatInputTests {
    @Test func inputRenders() {
        #expect(renders(ChatInput(text: .constant("Hello"), onSend: {})))
    }
}
