// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct ChatMessageList: View {
    let messages: [ChatMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
                        switch message.role {
                        case .user:
                            Text(message.text)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Color(.secondarySystemBackground),
                                    in: RoundedRectangle(cornerRadius: 18)
                                )
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        case .agent:
                            Text(message.text)
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
        ChatMessage(id: "1", role: .agent, text: "Hi, how can I help you?"),
        ChatMessage(id: "2", role: .user, text: "I want to place an order"),
    ])
}
