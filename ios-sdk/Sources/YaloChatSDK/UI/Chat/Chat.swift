// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The chat screen: a header, the conversation and the message input.
public struct Chat: View {
    private let title: String
    @State private var draft: String = ""

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        VStack(spacing: 0) {
            ChatHeader(title: title)
            ChatMessageList(messages: [])
            ChatInput(text: $draft, onSend: {})
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    Chat(title: "Yalo")
}
