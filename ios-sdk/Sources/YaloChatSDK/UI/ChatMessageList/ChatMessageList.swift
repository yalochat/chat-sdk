// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The conversation. Postback and link buttons stay under the message that sent them,
/// and the quick replies of `quickRepliesMessageId` are drawn under it.
/// `isWelcome` centers what the channel says, draws `avatar` above it and
/// stacks its quick replies one per line. With `showsFeedback`, text from the
/// channel can be rated with a thumbs up or down through `onRate`, once the
/// person has said something, so the welcome message never is.
struct ChatMessageList: View {
    /// Short enough that a message never feels held back, long enough that one
    /// arriving is noticed rather than found already there.
    private static let fade: Animation = .easeOut(duration: 0.22)
    /// The last row, so scrolling to it shows the very end.
    private static let bottomId: String = "yalo-chat-message-list-bottom"

    let messages: [ChatMessage]
    var isWaitingForReply: Bool = false
    var quickRepliesMessageId: Int64?
    var isWelcome: Bool = false
    var avatar: AnyView?
    var onTapButton: (MessageButton) -> Void = { _ in }
    var playback: VoicePlayback?
    var onToggleVoiceMessage: (ChatMessage) -> Void = { _ in }
    var cachedImage: (ChatMessage) -> UIImage? = { _ in nil }
    var loadImage: (ChatMessage) async -> UIImage? = { _ in nil }
    var showsFeedback: Bool = false
    var onRate: (ChatMessage, ChatMessage.Feedback) -> Void = { _, _ in }
    @Environment(\.chatTheme) private var theme: ChatTheme
    /// Whether the end of the conversation is on screen. A picture that loads
    /// grows its row, which would push the end away from someone reading it.
    @State private var showsEnd: Bool = false

    /// The replies after the person's first message, the only ones that can be rated.
    var rateableIds: Set<Int64> {
        Set(messages.drop { $0.role != .user }.filter { $0.role == .agent }.compactMap(\.id))
    }

    var body: some View {
        let rateable: Set<Int64> = showsFeedback ? rateableIds : []
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if isWelcome, let avatar {
                        avatar
                            .frame(maxWidth: .infinity)
                            .accessibilityIdentifier("yalo-chat-welcome-avatar")
                            .transition(.opacity)
                    }
                    ForEach(messages) { message in
                        VStack(alignment: isWelcome ? .center : .leading, spacing: 8) {
                            switch (message.role, message.type, message.type == .voice ? message.voice : nil) {
                            case (.user, .image, _):
                                ImageMessage(message: message, cached: cachedImage(message), load: loadImage) {
                                    if showsEnd {
                                        proxy.scrollTo(Self.bottomId, anchor: .bottom)
                                    }
                                }
                                .accessibilityIdentifier("yalo-chat-user-message")
                                .padding(.leading, 48)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            case (.agent, .image, _):
                                ImageMessage(message: message, cached: cachedImage(message), load: loadImage) {
                                    if showsEnd {
                                        proxy.scrollTo(Self.bottomId, anchor: .bottom)
                                    }
                                }
                                .foregroundStyle(theme.onAgentMessageBackground)
                                .accessibilityIdentifier("yalo-chat-agent-message")
                                .padding(.trailing, isWelcome ? 0 : 48)
                                .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                            case (.user, _, let note?):
                                VoiceMessage(
                                    note: note,
                                    playback: playback?.messageId == message.id ? playback : nil,
                                    onToggle: { onToggleVoiceMessage(message) }
                                )
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .foregroundStyle(theme.onUserMessageBackground)
                                .background(theme.userMessageBackground, in: theme.userMessageShape)
                                .accessibilityIdentifier("yalo-chat-user-message")
                                .padding(.leading, 48)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                            case (.agent, _, let note?):
                                VoiceMessage(
                                    note: note,
                                    playback: playback?.messageId == message.id ? playback : nil,
                                    onToggle: { onToggleVoiceMessage(message) }
                                )
                                .foregroundStyle(theme.onAgentMessageBackground)
                                .agentMessageBox(theme)
                                .accessibilityIdentifier("yalo-chat-agent-message")
                                .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                            case (.user, _, nil):
                                // Verbatim: asterisks the person typed are asterisks they meant.
                                Text(verbatim: message.content)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 10)
                                    .foregroundStyle(theme.onUserMessageBackground)
                                    .background(theme.userMessageBackground, in: theme.userMessageShape)
                                    .accessibilityIdentifier("yalo-chat-user-message")
                                    .padding(.leading, 48)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            case (.agent, _, nil):
                                Text(markdown(message.content))
                                    .multilineTextAlignment(isWelcome ? .center : .leading)
                                    .foregroundStyle(theme.onAgentMessageBackground)
                                    .agentMessageBox(theme)
                                    .accessibilityIdentifier("yalo-chat-agent-message")
                                    .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                            }
                            if message.role == .agent, !message.actions.isEmpty {
                                MessageButtons(buttons: message.actions, onTap: onTapButton)
                                    .padding(.horizontal, isWelcome ? 24 : 0)
                                    .padding(.trailing, isWelcome ? 0 : 48)
                            }
                            if let id = message.id, rateable.contains(id), message.type == .text, message.wiId != nil {
                                FeedbackButtons(feedback: message.feedback) { feedback in
                                    onRate(message, feedback)
                                }
                                .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                            }
                            if let id = message.id, id == quickRepliesMessageId {
                                QuickReplies(replies: message.quickReplies, onTap: onTapButton, vertical: isWelcome)
                                    .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                            }
                        }
                    }
                    .transition(.opacity)
                    if isWaitingForReply {
                        TypingIndicator()
                            .transition(.opacity)
                    }
                    // The bottom margin, as a row of its own so it is measured
                    // with the messages. With the spacing above it, 12 points.
                    Color.clear
                        .frame(height: 4)
                        .id(Self.bottomId)
                        .onAppear {
                            showsEnd = true
                        }
                        .onDisappear {
                            showsEnd = false
                        }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                // A message fades in where it lands, and the ones already there
                // slide up to make room for it.
                .animation(Self.fade, value: messages.last?.id)
                .animation(Self.fade, value: isWaitingForReply)
                .animation(Self.fade, value: quickRepliesMessageId)
                .animation(Self.fade, value: isWelcome)
            }
            .onAppear {
                proxy.scrollTo(Self.bottomId, anchor: .bottom)
            }
            .onChange(of: messages.last?.id) { _ in
                proxy.scrollTo(Self.bottomId, anchor: .bottom)
            }
            .onChange(of: isWaitingForReply) { waiting in
                if waiting {
                    proxy.scrollTo(Self.bottomId, anchor: .bottom)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier("yalo-chat-message-list")
    }
}

#Preview {
    ChatMessageList(messages: [
        ChatMessage(
            role: .agent,
            type: .text,
            timestamp: Date(),
            id: 1,
            content: "## Welcome\n\nHi, how can I **help** you?\n\n- Orders\n- Payments"
        ),
        ChatMessage(role: .user, type: .text, timestamp: Date(), id: 2, content: "I want to place an order"),
        ChatMessage(
            role: .agent,
            type: .text,
            timestamp: Date(),
            id: 3,
            content: "What would you like?",
            buttons: [
                MessageButton(text: "See the menu", kind: .postback),
                MessageButton(text: "Pizza"),
                MessageButton(text: "Burger"),
            ]
        ),
    ], quickRepliesMessageId: 3)
}

private extension View {
    func agentMessageBox(_ theme: ChatTheme) -> some View {
        padding(theme.agentMessagePadding)
            .background(theme.agentMessageBackground, in: theme.agentMessageShape)
            .overlay(theme.agentMessageShape.strokeBorder(theme.agentMessageBorderColor))
    }
}
