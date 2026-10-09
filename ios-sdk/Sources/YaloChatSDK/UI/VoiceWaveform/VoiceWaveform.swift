// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// A voice note drawn as bars, one per amplitude.
///
/// `progress` runs from zero to one: the bars behind it are solid and the ones
/// ahead are faded. The color is the foreground style of wherever it is drawn,
/// so it reads in the footer and in both kinds of bubble.
struct VoiceWaveform: View {
    static let maximumBarWidth: CGFloat = 3
    /// A silence is still drawn as a line rather than a gap.
    static let minimumBarHeight: CGFloat = 2
    /// How much of its share of the width a bar takes.
    static let barShare: CGFloat = 0.6
    static let trackOpacity: Double = 0.35

    let amplitudes: [Float]
    var progress: Double = 1

    var body: some View {
        Canvas { context, size in
            for bar in Self.bars(amplitudes: amplitudes, size: size, progress: progress) {
                context.fill(
                    Path(roundedRect: bar.rect, cornerRadius: bar.rect.width / 2),
                    with: .style(.foreground.opacity(bar.isPlayed ? 1 : Self.trackOpacity))
                )
            }
        }
        .accessibilityHidden(true)
    }

    struct Bar: Equatable {
        let rect: CGRect
        let isPlayed: Bool
    }

    /// The bars share the width evenly, each centered in its share.
    static func bars(amplitudes: [Float], size: CGSize, progress: Double) -> [Bar] {
        guard !amplitudes.isEmpty, size.width > 0, size.height > 0 else {
            return []
        }
        let slot: CGFloat = size.width / CGFloat(amplitudes.count)
        let width: CGFloat = min(maximumBarWidth, slot * barShare)
        let floor: CGFloat = min(minimumBarHeight, size.height)
        let played: Int = Int((Double(amplitudes.count) * min(max(progress, 0), 1)).rounded())
        return amplitudes.enumerated().map { index, level in
            let height: CGFloat = floor + (size.height - floor) * CGFloat(min(max(level, 0), 1))
            return Bar(
                rect: CGRect(
                    x: CGFloat(index) * slot + (slot - width) / 2,
                    y: (size.height - height) / 2,
                    width: width,
                    height: height
                ),
                isPlayed: index < played
            )
        }
    }

    /// A length as minutes and seconds, the way a chat writes it.
    static func duration(_ seconds: TimeInterval) -> String {
        let total: Int = max(Int(seconds), 0)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

#Preview {
    VoiceWaveform(amplitudes: (0..<40).map { index in Float(index % 7) / 7 }, progress: 0.4)
        .frame(width: 140, height: 24)
}
