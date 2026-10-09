// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct ChatMessageList: View {
    /// Short enough that a message never feels held back, long enough that one
    /// arriving is noticed rather than found already there.
    private static let fade: Animation = .easeOut(duration: 0.22)
    /// The last row, so scrolling to it shows the very end.
    private static let bottomId: String = "yalo-chat-message-list-bottom"

    let messages: [ChatMessage]
    var isWaitingForReply: Bool = false
    var playback: VoicePlayback?
    var onToggleVoiceMessage: (ChatMessage) -> Void = { _ in }
    var cachedImage: (ChatMessage) -> UIImage? = { _ in nil }
    var loadImage: (ChatMessage) async -> UIImage? = { _ in nil }
    @Environment(\.chatTheme) private var theme: ChatTheme
    /// Whether the end of the conversation is on screen. A picture that loads
    /// grows its row, which would push the end away from someone reading it.
    @State private var showsEnd: Bool = false

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages) { message in
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
                            .padding(.trailing, 48)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        case (.user, _, let note?):
                            VoiceMessage(
                                note: note,
                                playback: playback?.messageId == message.id ? playback : nil,
                                onToggle: { onToggleVoiceMessage(message) }
                            )
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .foregroundStyle(theme.onUserMessageBackground)
                            .background(theme.userMessageBackground, in: RoundedRectangle(cornerRadius: 18))
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
                            .background(theme.agentMessageBackground)
                            .accessibilityIdentifier("yalo-chat-agent-message")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        case (.user, _, nil):
                            // Verbatim: asterisks the person typed are asterisks they meant.
                            Text(verbatim: message.content)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .foregroundStyle(theme.onUserMessageBackground)
                                .background(theme.userMessageBackground, in: RoundedRectangle(cornerRadius: 18))
                                .accessibilityIdentifier("yalo-chat-user-message")
                                .padding(.leading, 48)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        case (.agent, _, nil):
                            Text(markdown(message.content))
                                .foregroundStyle(theme.onAgentMessageBackground)
                                .background(theme.agentMessageBackground)
                                .accessibilityIdentifier("yalo-chat-agent-message")
                                .frame(maxWidth: .infinity, alignment: .leading)
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
    ], isWaitingForReply: true)
}
