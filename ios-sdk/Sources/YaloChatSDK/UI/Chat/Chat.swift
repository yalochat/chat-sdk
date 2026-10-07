// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The chat screen: a header, the conversation and the message input.
public struct Chat: View {
    private let client: YaloChatClient
    private let theme: ChatTheme
    @State private var draft: String = ""

    public init(client: YaloChatClient, theme: ChatTheme = ChatTheme()) {
        self.client = client
        self.theme = theme
    }

    public var body: some View {
        VStack(spacing: 0) {
            ChatHeader(title: client.config.channelName, hideWatermark: client.config.hideWatermark)
            ChatMessageList(messages: [])
            ChatInput(text: $draft, onSend: {})
        }
        .background(theme.background)
        .environment(\.chatTheme, theme)
    }
}

#Preview {
    Chat(client: YaloChatClient(config: YaloChatClientConfig(
        channelId: "channel",
        organizationId: "organization",
        channelName: "Yalo"
    )))
}
