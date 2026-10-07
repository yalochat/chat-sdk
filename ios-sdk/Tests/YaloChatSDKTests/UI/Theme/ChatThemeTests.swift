// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

struct ChatThemeTests {
    @Test func overridingOneValueKeepsTheRestDefault() {
        var expected: ChatTheme = ChatTheme()
        expected.headerBackground = .indigo

        #expect(ChatTheme(headerBackground: .indigo) == expected)
        #expect(ChatTheme(headerBackground: .indigo) != ChatTheme())
    }

    @Test func chatUsesTheDefaultThemeWhenNoneIsProvided() {
        #expect(EnvironmentValues().chatTheme == ChatTheme())
    }
}
