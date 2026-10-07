// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct ChatMessageList: View {
    let messages: [ChatMessage]
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        switch message.role {
                        case .user:
                            Text(message.content)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .foregroundStyle(theme.onUserMessageBackground)
                                .background(theme.userMessageBackground, in: RoundedRectangle(cornerRadius: 18))
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        case .agent:
                            Text(message.content)
                                .foregroundStyle(theme.onAgentMessageBackground)
                                .background(theme.agentMessageBackground)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onAppear {
                proxy.scrollTo(messages.last?.id, anchor: .bottom)
            }
            .onChange(of: messages.last?.id) { id in
                proxy.scrollTo(id, anchor: .bottom)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("yalo-chat-message-list")
    }
}

#Preview {
    ChatMessageList(messages: [
        ChatMessage(role: .agent, type: .text, timestamp: Date(), id: 1, content: "Hi, how can I help you?"),
        ChatMessage(role: .user, type: .text, timestamp: Date(), id: 2, content: "I want to place an order"),
    ])
}
