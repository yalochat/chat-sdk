// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct TypingIndicatorView: View {
    @Environment(\.chatTheme) private var theme
    @State private var phase: Double = 0

    var body: some View {
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
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }
}
