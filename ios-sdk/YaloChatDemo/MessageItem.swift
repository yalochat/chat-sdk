// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct MessageItem: View {

    let message: ChatMessage

    private var isUser: Bool { message.role === MessageRole.user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isUser {
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
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.type is MessageType.Text {
            Text(message.content)
                .foregroundColor(isUser ? .white : .primary)
        } else {
            Text("Unsupported message type")
                .font(.caption)
                .italic()
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
        }
    }

    private var bubbleColor: Color {
        isUser ? .accentColor : Color(.systemGray5)
    }
}
