// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// A thumbs up and a thumbs down under a message from the channel. The one
/// the person picked stays filled.
struct FeedbackButtons: View {
    let feedback: ChatMessage.Feedback?
    var onRate: (ChatMessage.Feedback) -> Void = { _ in }
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        HStack(spacing: 4) {
            ForEach(
                [
                    (ChatMessage.Feedback.thumbsUp, "hand.thumbsup", Text("Good response", bundle: .module), "yalo-chat-thumbs-up-button"),
                    (ChatMessage.Feedback.thumbsDown, "hand.thumbsdown", Text("Bad response", bundle: .module), "yalo-chat-thumbs-down-button"),
                ],
                id: \.0
            ) { option, symbol, label, identifier in
                let picked: Bool = feedback == option
                Button {
                    onRate(option)
                } label: {
                    Image(systemName: picked ? "\(symbol).fill" : symbol)
                        .imageScale(.small)
                        .frame(width: 32, height: 32)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(theme.onAgentMessageBackground.opacity(picked ? 1 : 0.6))
                .accessibilityLabel(label)
                .accessibilityAddTraits(picked ? .isSelected : [])
                .accessibilityIdentifier(identifier)
            }
        }
    }
}

#Preview {
    FeedbackButtons(feedback: .thumbsUp)
}
