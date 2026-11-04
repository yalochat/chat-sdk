// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import Testing
import UIKit
@testable import YaloChatSDK

struct ScrollbarThumbTests {
    @Test func drawsNoThumbWhileEverythingFits() {
        let metrics: InputScrollMetrics = InputScrollMetrics(offset: 0, contentHeight: 80, visibleHeight: 80)

        #expect(scrollbarThumb(metrics: metrics) == nil)
    }

    @Test func drawsNoThumbBeforeTheInputIsLaidOut() {
        #expect(scrollbarThumb(metrics: InputScrollMetrics()) == nil)
    }

    @Test func sizesTheThumbToTheShareOfTheTextInView() {
        let metrics: InputScrollMetrics = InputScrollMetrics(offset: 0, contentHeight: 200, visibleHeight: 80)

        #expect(scrollbarThumb(metrics: metrics) == ScrollbarThumb(top: 0, height: 32))
    }

    @Test func movesTheThumbToTheBottomOnceScrolledToTheEnd() {
        let metrics: InputScrollMetrics = InputScrollMetrics(offset: 120, contentHeight: 200, visibleHeight: 80)

        #expect(scrollbarThumb(metrics: metrics) == ScrollbarThumb(top: 48, height: 32))
    }

    @Test(arguments: [CGFloat(-30), CGFloat(500)])
    func keepsTheThumbInsideTheTrackWhileTheTextBounces(offset: CGFloat) throws {
        let metrics: InputScrollMetrics = InputScrollMetrics(offset: offset, contentHeight: 200, visibleHeight: 80)
        let thumb: ScrollbarThumb = try #require(scrollbarThumb(metrics: metrics))

        #expect(thumb.top >= 0)
        #expect(thumb.top + thumb.height <= 80)
    }

    @Test func keepsAVeryLongTextsThumbVisible() {
        let metrics: InputScrollMetrics = InputScrollMetrics(offset: 0, contentHeight: 100_000, visibleHeight: 80)

        #expect(scrollbarThumb(metrics: metrics)?.height == inputScrollbarMinThumbHeight)
    }
}

@MainActor
struct ChatInputTextViewTests {
    @Test func returnSendsInsteadOfStartingANewLine() {
        var sent: Int = 0
        let coordinator: ChatInputTextView.Coordinator = makeCoordinator(onSend: { sent += 1 })

        let accepted: Bool = coordinator.textView(UITextView(), shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "\n")

        #expect(!accepted)
        #expect(sent == 1)
    }

    @Test func letsOtherTextThrough() {
        var sent: Int = 0
        let coordinator: ChatInputTextView.Coordinator = makeCoordinator(onSend: { sent += 1 })

        let accepted: Bool = coordinator.textView(UITextView(), shouldChangeTextIn: NSRange(location: 0, length: 0), replacementText: "Hi")

        #expect(accepted)
        #expect(sent == 0)
    }

    @Test func reportsWhatTheUserTypes() {
        var text: String = ""
        let coordinator: ChatInputTextView.Coordinator = makeCoordinator(text: Binding(get: { text }, set: { text = $0 }))
        let textView: UITextView = UITextView()
        textView.text = "Hello"

        coordinator.textViewDidChange(textView)

        #expect(text == "Hello")
    }

    @Test func staysOneLineTallForShortText() {
        let textView: UITextView = makeTextView(text: "Hi")

        #expect(fittingHeight(of: textView) == naturalHeight(of: textView))
    }

    @Test func growsWithEachLineUpToTheCap() {
        let one: UITextView = makeTextView(text: lines(1))
        let three: UITextView = makeTextView(text: lines(3))

        #expect(fittingHeight(of: three) == naturalHeight(of: three))
        #expect(fittingHeight(of: three) > fittingHeight(of: one))
    }

    // Exactly as many lines as the cap fit without scrolling, so the thumb only
    // shows once there is more text than the box holds.
    @Test func fitsTheCappedNumberOfLinesWithoutScrolling() {
        let textView: UITextView = makeTextView(text: lines(inputMaxLines))

        #expect(fittingHeight(of: textView) == naturalHeight(of: textView))
    }

    @Test func stopsGrowingAtTheLineCap() {
        let capped: UITextView = makeTextView(text: lines(inputMaxLines))
        let long: UITextView = makeTextView(text: lines(20))

        #expect(fittingHeight(of: long) == fittingHeight(of: capped))
        #expect(naturalHeight(of: long) > fittingHeight(of: long))
    }

    @Test func rendersALongTextWithACustomScrollbar() {
        let text: String = lines(20)
        let theme: ChatTheme = ChatTheme(inputScrollbarColor: .red, inputScrollbarWidth: 6)

        #expect(renders(ChatInput(text: .constant(text), onSend: {}).environment(\.chatTheme, theme)))
    }

    @Test func rendersWithTheScrollbarHidden() {
        let text: String = lines(20)
        let theme: ChatTheme = ChatTheme(inputScrollbarWidth: 0)

        #expect(renders(ChatInput(text: .constant(text), onSend: {}).environment(\.chatTheme, theme)))
    }

    private func makeCoordinator(
        text: Binding<String> = .constant(""),
        onSend: @escaping () -> Void = {}
    ) -> ChatInputTextView.Coordinator {
        ChatInputTextView(
            text: text,
            height: .constant(0),
            metrics: .constant(InputScrollMetrics()),
            textColor: .label,
            trailingInset: 0,
            accessibilityLabel: "",
            onSend: onSend
        ).makeCoordinator()
    }

    private func lines(_ count: Int) -> String {
        (1...count).map { "Line \($0)" }.joined(separator: "\n")
    }

    private func naturalHeight(of textView: UITextView) -> CGFloat {
        ceil(textView.sizeThatFits(CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)).height)
    }

    private func makeTextView(text: String) -> UITextView {
        let textView: UITextView = UITextView(frame: CGRect(x: 0, y: 0, width: 240, height: 40))
        textView.font = .preferredFont(forTextStyle: .body)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.text = text
        return textView
    }
}
