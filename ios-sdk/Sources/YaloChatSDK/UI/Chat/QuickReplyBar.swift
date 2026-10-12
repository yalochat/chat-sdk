// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The quick replies of the moment, in a bar between the conversation and the
/// message input.
///
/// It takes its room at once and only fades its content in, since a list
/// shrinking under an animation stops short of its end.
struct QuickReplyBar: View {
    let replies: [MessageButton]
    var onTap: (MessageButton) -> Void = { _ in }
    @Environment(\.chatTheme) private var theme: ChatTheme
    @State private var shown: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            QuickReplies(replies: replies, onTap: onTap)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .opacity(shown ? 1 : 0)
        }
        .background(theme.background)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("yalo-chat-quick-replies")
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                shown = true
            }
        }
    }
}
