// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct TypingIndicatorView: View {
    @Environment(\.chatTheme) private var theme

    var body: some View {
        TimelineView(.animation) { timeline in
            let phase = timeline.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: 1.2) / 1.2
            HStack(spacing: 4) {
                ForEach(0..<3, id: \.self) { i in
                    let t = (phase + Double(i) * 0.2).truncatingRemainder(dividingBy: 1.0)
                    let wave = sin(t * .pi)
                    Circle()
                        .fill(theme.typingIndicatorDotColor)
                        .frame(width: 8, height: 8)
                        .offset(y: -wave * 4)
                        .opacity(0.3 + 0.7 * wave)
                }
            }
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
