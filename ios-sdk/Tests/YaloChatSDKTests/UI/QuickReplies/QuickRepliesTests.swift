// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct QuickRepliesTests {
    private let replies: [MessageButton] = ["Track my order", "Talk to a person", "See the menu", "Payments"].map { text in
        MessageButton(text: text)
    }

    private func height(of view: some View, width: CGFloat) -> CGFloat {
        UIHostingController(rootView: view).sizeThatFits(in: CGSize(width: width, height: .greatestFiniteMagnitude)).height
    }

    @Test func quickRepliesRender() {
        #expect(renders(QuickReplies(replies: replies)))
    }

    @Test func quickRepliesWrapOntoMoreLinesWhenTheyDoNotFit() {
        let oneLine: CGFloat = height(of: QuickReplies(replies: [replies[0]]), width: 1_000)

        #expect(height(of: QuickReplies(replies: replies), width: 1_000) == oneLine)
        #expect(height(of: QuickReplies(replies: replies), width: 200) > oneLine * 3)
    }

    @Test func aReplyWiderThanALineWrapsItsText() {
        let long: MessageButton = MessageButton(text: String(repeating: "A very long answer ", count: 10))

        #expect(height(of: QuickReplies(replies: [long]), width: 200) > height(of: QuickReplies(replies: [replies[0]]), width: 200))
    }

    @Test func verticalQuickRepliesTakeALineEach() {
        let oneLine: CGFloat = height(of: QuickReplies(replies: [replies[0]], vertical: true), width: 1_000)

        #expect(height(of: QuickReplies(replies: replies, vertical: true), width: 1_000) > oneLine * 4)
    }

    @Test func quickReplyBarRenders() {
        #expect(renders(QuickReplyBar(replies: replies)))
    }
}
