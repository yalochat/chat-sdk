// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// Lays its views out left to right and wraps onto as many lines as they
/// need. A view wider than a line gets the whole line.
@available(iOS 16.0, *)
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(subviews, width: proposal.width ?? .infinity).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames: [CGRect] = arrange(subviews, width: bounds.width).frames
        for (subview, frame) in zip(subviews, frames) {
            subview.place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(_ subviews: Subviews, width: CGFloat) -> (frames: [CGRect], size: CGSize) {
        var frames: [CGRect] = []
        var origin: CGPoint = .zero
        var lineHeight: CGFloat = 0
        var widest: CGFloat = 0
        for subview in subviews {
            var size: CGSize = subview.sizeThatFits(.unspecified)
            if size.width > width {
                size = subview.sizeThatFits(ProposedViewSize(width: width, height: nil))
            }
            if origin.x > 0, origin.x + size.width > width {
                origin = CGPoint(x: 0, y: origin.y + lineHeight + spacing)
                lineHeight = 0
            }
            frames.append(CGRect(origin: origin, size: size))
            widest = max(widest, origin.x + size.width)
            lineHeight = max(lineHeight, size.height)
            origin.x += size.width + spacing
        }
        return (frames, CGSize(width: widest, height: origin.y + lineHeight))
    }
}
