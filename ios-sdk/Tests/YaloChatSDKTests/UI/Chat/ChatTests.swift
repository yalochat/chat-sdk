// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

@MainActor
struct ChatTests {
    @Test func chatRenders() {
        #expect(renders(Chat(title: "Yalo")))
    }
}
