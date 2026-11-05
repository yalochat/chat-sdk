// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import UIKit

let inputMaxLines: Int = 4

let inputScrollbarGap: CGFloat = 4

let inputScrollbarMinThumbHeight: CGFloat = 16

struct InputScrollMetrics: Equatable {
    var offset: CGFloat = 0
    var contentHeight: CGFloat = 0
    var visibleHeight: CGFloat = 0
}

struct ScrollbarThumb: Equatable {
    var top: CGFloat
    var height: CGFloat
}

/// `nil` while everything fits.
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

/// A `UITextView` because `TextField` cannot style its scroll indicator or grow on iOS 15.
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
        // Skipped mid composition so multi key input is not interrupted.
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

        // Deferred: runs during layout, when SwiftUI state cannot change.
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

/// Measured, since laid out lines are taller than `font.lineHeight`.
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

final class InputTextView: UITextView {
    var onLayout: ((UITextView) -> Void)?

    override func layoutSubviews() {
        super.layoutSubviews()
        onLayout?(self)
    }
}
