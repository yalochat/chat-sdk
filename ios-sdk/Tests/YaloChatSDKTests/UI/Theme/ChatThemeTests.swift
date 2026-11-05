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

    @Test func defaultInputShapeLooksLikeACapsuleAtOneLine() {
        let oneLine: CGRect = CGRect(x: 0, y: 0, width: 300, height: 42)

        #expect(ChatTheme().inputShape.path(in: oneLine) == ChatShape.capsule.path(in: oneLine))
    }

    @Test func defaultInputShapeKeepsSmallCornersOnceTaller() {
        let fourLines: CGRect = CGRect(x: 0, y: 0, width: 300, height: 108)
        let besideTheFirstLine: CGPoint = CGPoint(x: 3, y: 30)

        #expect(ChatTheme().inputShape.path(in: fourLines).contains(besideTheFirstLine))
        #expect(!ChatShape.capsule.path(in: fourLines).contains(besideTheFirstLine))
    }

    @Test func chatUsesTheDefaultThemeWhenNoneIsProvided() {
        #expect(EnvironmentValues().chatTheme == ChatTheme())
    }
}
