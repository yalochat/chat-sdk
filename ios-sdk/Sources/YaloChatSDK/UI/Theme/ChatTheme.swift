// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// How the chat paints itself.
///
/// Every value defaults to a system color, so the chat follows light and dark
/// mode with no setup. Override only what you need:
///
/// ```swift
/// Chat(client: client, theme: ChatTheme(headerBackground: .indigo, onHeaderBackground: .white))
/// ```
public struct ChatTheme: Sendable, Equatable {
    public var background: Color
    public var headerBackground: Color
    public var onHeaderBackground: Color
    public var footerBackground: Color
    public var onFooterBackground: Color
    public var inputBorderColor: Color
    public var inputBackground: Color
    public var inputShape: ChatShape
    public var sendButtonBackground: Color
    public var onSendButtonBackground: Color
    public var userMessageBackground: Color
    public var onUserMessageBackground: Color
    public var agentMessageBackground: Color
    public var onAgentMessageBackground: Color
    public var agentMessageShape: ChatShape
    public var agentMessageBorderColor: Color
    public var agentMessagePadding: CGFloat
    public var typingIndicatorDotColor: Color
    public var quickReplyBackground: Color
    public var onQuickReplyBackground: Color
    public var quickReplyBorderColor: Color
    public var quickReplyShape: ChatShape
    public var postbackBackground: Color
    public var onPostbackBackground: Color
    public var postbackBorderColor: Color

    public init(
        background: Color = Color(.systemBackground),
        headerBackground: Color = Color(.secondarySystemBackground),
        onHeaderBackground: Color = Color(.label),
        footerBackground: Color = Color(.secondarySystemBackground),
        onFooterBackground: Color = Color(.label),
        inputBorderColor: Color = Color(.separator),
        inputBackground: Color = .clear,
        inputShape: ChatShape = .capsule,
        sendButtonBackground: Color = .accentColor,
        onSendButtonBackground: Color = .white,
        userMessageBackground: Color = Color(.secondarySystemBackground),
        onUserMessageBackground: Color = Color(.label),
        // Unbubbled, like the web SDK, so it reads as the conversation itself.
        agentMessageBackground: Color = .clear,
        onAgentMessageBackground: Color = Color(.label),
        agentMessageShape: ChatShape = ChatShape(radius: 0),
        agentMessageBorderColor: Color = .clear,
        agentMessagePadding: CGFloat = 0,
        typingIndicatorDotColor: Color = Color(.secondaryLabel),
        // Outlined rather than filled, like the web SDK, so a quick reply reads
        // as an offer rather than as something said.
        quickReplyBackground: Color = .clear,
        onQuickReplyBackground: Color = Color(.label),
        quickReplyBorderColor: Color = Color(.separator),
        quickReplyShape: ChatShape = .capsule,
        postbackBackground: Color = .clear,
        onPostbackBackground: Color = Color(.label),
        postbackBorderColor: Color = Color(.separator)
    ) {
        self.background = background
        self.headerBackground = headerBackground
        self.onHeaderBackground = onHeaderBackground
        self.footerBackground = footerBackground
        self.onFooterBackground = onFooterBackground
        self.inputBorderColor = inputBorderColor
        self.inputBackground = inputBackground
        self.inputShape = inputShape
        self.sendButtonBackground = sendButtonBackground
        self.onSendButtonBackground = onSendButtonBackground
        self.userMessageBackground = userMessageBackground
        self.onUserMessageBackground = onUserMessageBackground
        self.agentMessageBackground = agentMessageBackground
        self.onAgentMessageBackground = onAgentMessageBackground
        self.agentMessageShape = agentMessageShape
        self.agentMessageBorderColor = agentMessageBorderColor
        self.agentMessagePadding = agentMessagePadding
        self.typingIndicatorDotColor = typingIndicatorDotColor
        self.quickReplyBackground = quickReplyBackground
        self.onQuickReplyBackground = onQuickReplyBackground
        self.quickReplyBorderColor = quickReplyBorderColor
        self.quickReplyShape = quickReplyShape
        self.postbackBackground = postbackBackground
        self.onPostbackBackground = onPostbackBackground
        self.postbackBorderColor = postbackBorderColor
    }
}

extension EnvironmentValues {
    @Entry var chatTheme: ChatTheme = ChatTheme()
}
