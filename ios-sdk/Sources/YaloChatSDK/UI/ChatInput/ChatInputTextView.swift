// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import UIKit

/// How many lines the input grows to before what is typed scrolls inside it.
let inputMaxLines: Int = 4

/// Room between the scrollbar thumb and the text it sits beside.
let inputScrollbarGap: CGFloat = 4

/// The shortest the scrollbar thumb gets, so a very long text still leaves
/// something to see.
let inputScrollbarMinThumbHeight: CGFloat = 16

/// Where the input's scroll sits, as the text view reports it.
struct InputScrollMetrics: Equatable {
    var offset: CGFloat = 0
    var contentHeight: CGFloat = 0
    var visibleHeight: CGFloat = 0
}

/// The scrollbar thumb, measured from the top of the input's visible text.
struct ScrollbarThumb: Equatable {
    var top: CGFloat
    var height: CGFloat
}

/// Where the scrollbar thumb goes for `metrics`, or `nil` while everything fits.
///
/// The thumb runs down the whole visible height. It is as tall as the share of
/// the text in view, never shorter than `minThumbHeight`, and it stays inside
/// the track while the text bounces past either end.
func scrollbarThumb(
    metrics: InputScrollMetrics,
    minThumbHeight: CGFloat = inputScrollbarMinThumbHeight
) -> ScrollbarThumb? {
    let track: CGFloat = metrics.visibleHeight
    let maxScroll: CGFloat = metrics.contentHeight - track
    guard track > 0, maxScroll > 0.5 else {
        return nil
    }
    let height: CGFloat = min(max(track * track / metrics.contentHeight, min(minThumbHeight, track)), track)
    let progress: CGFloat = min(max(metrics.offset / maxScroll, 0), 1)
    return ScrollbarThumb(top: (track - height) * progress, height: height)
}

/// The text view behind the message input.
///
/// A SwiftUI `TextField` cannot have its scroll indicator styled, and on
/// iOS 15 it cannot grow past one line, so the input is a `UITextView`. It
/// grows to `inputMaxLines` lines and then scrolls, with the system indicator
/// off so `ChatInput` can draw one in the theme's color and width. Return sends
/// rather than starting a new line, as the send key on the keyboard says.
struct ChatInputTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var height: CGFloat
    @Binding var metrics: InputScrollMetrics
    var textColor: UIColor
    var trailingInset: CGFloat
    var accessibilityLabel: String
    let onSend: () -> Void

    func makeUIView(context: Context) -> InputTextView {
        let view: InputTextView = InputTextView()
        view.delegate = context.coordinator
        view.font = .preferredFont(forTextStyle: .body)
        view.adjustsFontForContentSizeCategory = true
        view.backgroundColor = .clear
        view.textContainerInset = .zero
        view.textContainer.lineFragmentPadding = 0
        view.isScrollEnabled = true
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.returnKeyType = .send
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.accessibilityIdentifier = "yalo-chat-input"
        view.text = text
        let coordinator: Coordinator = context.coordinator
        view.onLayout = { [weak coordinator] textView in
            coordinator?.report(textView)
        }
        return view
    }

    func updateUIView(_ view: InputTextView, context: Context) {
        context.coordinator.parent = self
        // Left alone mid composition, so a keyboard building a character out
        // of several keys is not interrupted by its own echo.
        if view.text != text, view.markedTextRange == nil {
            view.text = text
            context.coordinator.report(view)
        }
        view.textColor = textColor
        view.accessibilityLabel = accessibilityLabel
        if view.textContainerInset.right != trailingInset {
            view.textContainerInset.right = trailingInset
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    @MainActor
    final class Coordinator: NSObject, UITextViewDelegate {
        var parent: ChatInputTextView

        init(_ parent: ChatInputTextView) {
            self.parent = parent
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText text: String
        ) -> Bool {
            if text == "\n" {
                parent.onSend()
                return false
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            report(textView)
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if let textView = scrollView as? UITextView {
                report(textView)
            }
        }

        /// Tells `ChatInput` how tall the text view wants to be and where its
        /// scroll sits. Deferred, because this runs during layout and SwiftUI
        /// state must not change while a view is being updated.
        func report(_ textView: UITextView) {
            guard textView.bounds.width > 0 else {
                return
            }
            let height: CGFloat = fittingHeight(of: textView)
            let metrics: InputScrollMetrics = InputScrollMetrics(
                offset: textView.contentOffset.y,
                contentHeight: textView.contentSize.height,
                visibleHeight: textView.bounds.height
            )
            guard height != parent.height || metrics != parent.metrics else {
                return
            }
            DispatchQueue.main.async { [self] in
                if parent.height != height {
                    parent.height = height
                }
                if parent.metrics != metrics {
                    parent.metrics = metrics
                }
            }
        }
    }
}

/// The height `textView` needs for what is in it, from one line up to
/// `inputMaxLines`.
@MainActor
func fittingHeight(of textView: UITextView) -> CGFloat {
    let lineHeight: CGFloat = laidOutLineHeight(for: textView.font ?? .preferredFont(forTextStyle: .body))
    let insets: CGFloat = textView.textContainerInset.top + textView.textContainerInset.bottom
    let fitting: CGFloat = textView.sizeThatFits(
        CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
    ).height
    return min(max(ceil(fitting), lineHeight + insets), lineHeight * CGFloat(inputMaxLines) + insets)
}

@MainActor private var lineHeights: [UIFont: CGFloat] = [:]
@MainActor private let lineMeasure: UITextView = {
    let textView: UITextView = UITextView()
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.text = "X"
    return textView
}()

/// How far apart a text view lays out lines in `font`, which is more than
/// `font.lineHeight` once the layout rounds each line to the pixel grid.
@MainActor
func laidOutLineHeight(for font: UIFont) -> CGFloat {
    if let height = lineHeights[font] {
        return height
    }
    lineMeasure.font = font
    let height: CGFloat = ceil(lineMeasure.sizeThatFits(
        CGSize(width: CGFloat.greatestFiniteMagnitude, height: .greatestFiniteMagnitude)
    ).height)
    lineHeights[font] = height
    return height
}

/// A `UITextView` that says when it lays out, which is when its content size
/// settles after the text or the width changes.
final class InputTextView: UITextView {
    var onLayout: ((UITextView) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
}
