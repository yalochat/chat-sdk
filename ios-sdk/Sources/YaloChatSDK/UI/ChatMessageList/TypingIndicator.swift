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
        .accessibilityIdentifier("yalo-chat-typing-indicator")
    }
}

/// The "Writing..." text at the foot of the conversation while a reply is
/// expected. `text` replaces the built-in translation when given.
///
/// Each character fades in a little after the one before it, the way a reply
/// streams in token by token. The list fades it out when the reply lands.
struct TypingText: View {
    private static let tokenStagger: TimeInterval = 0.025
    private static let tokenFade: TimeInterval = 0.18

    var text: String?

    @Environment(\.chatTheme) private var theme: ChatTheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion: Bool
    @State private var start: Date = Date()

    var body: some View {
        let shown: String = text ?? String(localized: "Writing...", bundle: .module)
        TimelineView(.animation) { timeline in
            let elapsed: TimeInterval = reduceMotion ? .infinity : timeline.date.timeIntervalSince(start)
            Array(shown).enumerated().reduce(Text(verbatim: "")) { tokens, item in
                let opacity: Double = min(max((elapsed - Double(item.offset) * Self.tokenStagger) / Self.tokenFade, 0), 1)
                return tokens + Text(verbatim: String(item.element))
                    .foregroundColor(theme.typingIndicatorDotColor.opacity(opacity))
            }
        }
        .font(theme.font(.subheadline))
        .padding(.horizontal, 4)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: shown))
        .accessibilityAddTraits(.updatesFrequently)
        .accessibilityIdentifier("yalo-chat-typing-indicator")
    }
}

#Preview {
    TypingIndicator()
}

#Preview {
    TypingText()
}
