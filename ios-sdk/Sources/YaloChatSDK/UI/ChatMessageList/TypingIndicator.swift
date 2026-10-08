// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// Three dots at the foot of the conversation while a reply is expected.
///
/// Each dot runs the same cycle a fifth of a turn behind the one before it, so
/// they ripple rather than pulse together. The timings follow the Android SDK.
struct TypingIndicator: View {
    private static let cycle: TimeInterval = 1.2
    private static let dotCount: Int = 3
    private static let phaseStep: Double = 0.2
    private static let restingOpacity: Double = 0.4
    private static let dotSize: CGFloat = 8
    private static let maxLift: CGFloat = 4

    @Environment(\.chatTheme) private var theme: ChatTheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool

    var body: some View {
        TimelineView(.animation) { timeline in
            let progress: Double = timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: Self.cycle) / Self.cycle
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(0..<Self.dotCount, id: \.self) { index in
                    // Peaks halfway through this dot's turn of the cycle, then settles.
                    let turn: Double = (progress - Double(index) * Self.phaseStep + 1)
                        .truncatingRemainder(dividingBy: 1)
                    let lift: Double = max(sin(turn * .pi), 0)
                    Circle()
                        .fill(theme.typingIndicatorDotColor)
                        .frame(width: Self.dotSize, height: Self.dotSize)
                        .offset(y: reduceMotion ? 0 : -Self.maxLift * lift)
                        .opacity(Self.restingOpacity + (1 - Self.restingOpacity) * lift)
                }
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityIdentifier("yalo-chat-typing-indicator")
    }
}

#Preview {
    TypingIndicator()
}
