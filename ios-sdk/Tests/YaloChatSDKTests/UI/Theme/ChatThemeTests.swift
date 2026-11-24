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

    @Test func avatarsAreFilledByDefault() {
        let theme: ChatTheme = ChatTheme()

        #expect(theme.userAvatarBackground == Color(.systemGray5))
        #expect(theme.assistantAvatarBackground == .accentColor)
        #expect(ChatTheme(userAvatarBackground: .indigo) != theme)
    }

    @Test func textUsesTheSystemFontWhenNoFamilyIsSet() {
        #expect(ChatTheme().font(.body) == .body)
        #expect(ChatTheme().font(.caption) == .caption)
        #expect(ChatTheme().uiFont(.body) == .preferredFont(forTextStyle: .body))
    }

    @Test func textUsesTheFamilyTheHostRegistered() {
        let theme: ChatTheme = ChatTheme(fontFamily: "Georgia")

        #expect(theme.font(.body) != .body)
        #expect(theme.uiFont(.body).familyName == "Georgia")
    }

    @Test func inputKeepsItsSizeInTheHostFamily() {
        let font: UIFont = ChatTheme(fontFamily: "Georgia").uiFont(.body)

        #expect(font.pointSize == UIFont.preferredFont(forTextStyle: .body).pointSize)
    }

    @Test func inputFallsBackToTheSystemFontForAnUnknownFamily() {
        #expect(ChatTheme(fontFamily: "Not A Font").uiFont(.body) == .preferredFont(forTextStyle: .body))
    }

    @Test func markdownHeadingsUseTheThemeFont() {
        let theme: ChatTheme = ChatTheme(fontFamily: "Georgia")

        #expect(markdown("# Title", theme: theme).runs.first?.font == theme.font(.title2).bold())
    }
}
