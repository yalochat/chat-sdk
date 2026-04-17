// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

// Mirrors Flutter Message → UserMessage / AssistantMessage routing.
// Role dispatch: user = right-aligned bubble, agent = left-aligned bubble.
// Type dispatch: text renders content; all other types show a graceful fallback
// (improvement over Flutter's UnimplementedError — see M3 scope decision).
struct MessageItem: View {

    let message: ChatMessage

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.role == .user {
                Spacer(minLength: 48)
                bubble
            } else {
                bubble
                Spacer(minLength: 48)
            }
        }
    }

    private var bubble: some View {
        bubbleContent
            .padding(12)
            .background(bubbleColor)
            .cornerRadius(16)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.role == .user ? .trailing : .leading)
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.type is MessageTypeText {
            Text(message.content)
                .foregroundColor(message.role == .user ? .white : .primary)
        } else {
            Text("Unsupported message type")
                .font(.caption)
                .italic()
                .foregroundColor(message.role == .user ? .white.opacity(0.8) : .secondary)
        }
    }

    private var bubbleColor: Color {
        message.role == .user ? .accentColor : Color(.systemGray5)
    }
}
