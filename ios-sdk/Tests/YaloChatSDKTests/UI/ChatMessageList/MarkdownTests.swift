// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftUI
import Testing
@testable import YaloChatSDK

struct MarkdownTests {
    private func text(_ source: String) -> String {
        String(markdown(source).characters)
    }

    private func run(_ word: String, in source: String) throws -> AttributedString.Runs.Run {
        let rendered: AttributedString = markdown(source)
        let range: Range<AttributedString.Index> = try #require(rendered.range(of: word))
        return try #require(rendered[range].runs.first)
    }

    @Test(arguments: [
        ("Hello there", "Hello there"),
        ("One\n\nTwo", "One\n\nTwo"),
        ("**bold**, *italic* and ~~gone~~", "bold, italic and gone"),
        ("- Orders\n- Payments", "• Orders\n• Payments"),
        ("1. Orders\n2. Payments", "1. Orders\n2. Payments"),
        ("- Orders\n    - Open\n- Payments", "• Orders\n    • Open\n• Payments"),
        ("Pick one:\n\n- Orders\n\nThanks", "Pick one:\n\n• Orders\n\nThanks"),
        ("# Title\n\nBody", "Title\n\nBody"),
        ("```\nlet total = 1\n```", "let total = 1"),
        ("> Quoted", "Quoted"),
        ("[Yalo](https://yalo.com)", "Yalo"),
    ])
    func writesOutWhatTheMarkdownSays(source: String, expected: String) {
        #expect(text(source) == expected)
    }

    @Test func keepsInlineStylesForTextToDraw() throws {
        let source: String = "**bold** and `code`"

        #expect(try run("bold", in: source).inlinePresentationIntent == .stronglyEmphasized)
        #expect(try run("code", in: source).inlinePresentationIntent == .code)
    }

    @Test func keepsLinks() throws {
        #expect(try run("Yalo", in: "[Yalo](https://yalo.com)").link == URL(string: "https://yalo.com"))
    }

    @Test(arguments: [
        ("# Title", Font.title2.bold()),
        ("## Title", Font.title3.bold()),
        ("### Title", Font.headline),
    ])
    func sizesHeadingsByLevel(source: String, font: Font) throws {
        #expect(try run("Title", in: source).font == font)
    }

    @Test func drawsCodeBlocksMonospaced() throws {
        #expect(try run("total", in: "```\nlet total = 1\n```").font == .system(.body, design: .monospaced))
    }

    @Test func dimsQuotes() throws {
        #expect(try run("Quoted", in: "> Quoted").foregroundColor == .secondary)
    }
}
