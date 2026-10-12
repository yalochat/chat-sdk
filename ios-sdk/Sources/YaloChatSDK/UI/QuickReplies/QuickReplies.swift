// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The answers a message offers, as chips the person taps instead of typing.
///
/// They wrap onto as many lines as they need, since the channel writes them.
/// Before iOS 16 they scroll sideways instead. `vertical` stacks them one per
/// line, centered.
struct QuickReplies: View {
    let replies: [MessageButton]
    var onTap: (MessageButton) -> Void = { _ in }
    var vertical: Bool = false
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        if vertical {
            VStack(spacing: 8) {
                chips
            }
            .frame(maxWidth: .infinity)
        } else if #available(iOS 16.0, *) {
            FlowLayout(spacing: 8) {
                chips
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chips
                }
            }
        }
    }

    // Texts can repeat, so a chip is told apart by where it sits.
    private var chips: some View {
        ForEach(Array(replies.enumerated()), id: \.offset) { _, reply in
            Button {
                onTap(reply)
            } label: {
                Text(verbatim: reply.text)
                    .font(.subheadline.weight(.medium))
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: vertical ? .infinity : nil)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(theme.onQuickReplyBackground)
                    .background(theme.quickReplyBackground, in: Capsule())
                    .overlay(Capsule().strokeBorder(theme.quickReplyBorderColor))
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .frame(maxWidth: vertical ? 320 : nil)
            .accessibilityIdentifier("yalo-chat-quick-reply")
        }
    }
}

#Preview {
    QuickReplies(replies: [
        MessageButton(text: "Track my order"),
        MessageButton(text: "Talk to a person"),
        MessageButton(text: "See the menu"),
        MessageButton(text: "Payments"),
    ])
    .padding()
}
