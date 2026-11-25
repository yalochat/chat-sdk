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
    var onTapAction: (ChatMessage, MessageButton) -> Void = { _, _ in }
    var playback: VoicePlayback?
    var onToggleVoiceMessage: (ChatMessage) -> Void = { _ in }
    var cachedImage: (ChatMessage) -> UIImage? = { _ in nil }
    var loadImage: (ChatMessage) async -> UIImage? = { _ in nil }
    var cachedVideo: (ChatMessage) -> VideoPreview? = { _ in nil }
    var loadVideo: (ChatMessage) async -> VideoPreview? = { _ in nil }
    var showsFeedback: Bool = false
    var userMessageAvatar: YaloChatMessageAvatar = .none
    var assistantMessageAvatar: YaloChatMessageAvatar = .none
    var avatarDisplay: AvatarDisplay = .lastInGroup
    var typingIndicatorType: TypingIndicatorType = .threeDots
    var writingIndicatorText: String?
    var typingIndicatorAvatarPosition: TypingIndicatorAvatarPosition = .center
    var showTimestamps: Bool = false
    var messageButtonsPosition: MessageButtonsPosition = .belowMessage
    var onRate: (ChatMessage, ChatMessage.Feedback) -> Void = { _, _ in }
    @Environment(\.chatTheme) private var theme: ChatTheme
    /// Whether the end of the conversation is on screen. A picture that loads
    /// grows its row, which would push the end away from someone reading it.
    @State private var showsEnd: Bool = false

    /// The replies after the person's first message, the only ones that can be rated.
    var rateableIds: Set<Int64> {
        Set(messages.drop { $0.role != .user }.filter { $0.role == .agent }.compactMap(\.id))
    }

    /// The messages that keep the room of their avatar without drawing it:
    /// with `.lastInGroup`, all but the newest of each run sent by the same side.
    /// The typing indicator carries the assistant avatar, so it ends the run of
    /// the newest message when that one is the assistant's.
    var hiddenAvatarIds: Set<Int64> {
        guard avatarDisplay == .lastInGroup else {
            return []
        }
        var hidden: Set<Int64> = Set(zip(messages, messages.dropFirst()).filter { message, next in
            message.role == next.role
        }.compactMap { message, _ in message.id })
        if showsWritingAvatar, let newest = messages.last, newest.role == .agent, let id = newest.id {
            hidden.insert(id)
        }
        return hidden
    }

    /// The messages that start a day, so the day is drawn above them. Only with `showTimestamps`.
    var startsDayIds: Set<Int64> {
        guard showTimestamps else {
            return []
        }
        let calendar: Calendar = .current
        return Set(messages.enumerated().filter { index, message in
            index == 0 || !calendar.isDate(messages[index - 1].timestamp, inSameDayAs: message.timestamp)
        }.compactMap { _, message in message.id })
    }

    var showsWritingAvatar: Bool {
        isWaitingForReply && !isWelcome && assistantMessageAvatar != .none
    }

    /// The theme tail for a bubble that shows its avatar, or nil when it gets none.
    func tail(showsAvatar: Bool) -> CGSize? {
        let size: CGSize = theme.messageTailSize
        guard showsAvatar, size.width > 0, size.height > 0 else {
            return nil
        }
        return size
    }

    /// The tail of the typing indicator bubble: there when the avatar sits below it or there is no avatar.
    var writingTail: CGSize? {
        tail(showsAvatar: typingIndicatorAvatarPosition == .below || !showsWritingAvatar)
    }

    /// The buttons of `message` drawn inside its bubble, each as wide as its text.
    private func insideButtons(of message: ChatMessage) -> some View {
        Group {
            if message.role == .agent, !message.actions.isEmpty {
                MessageButtons(buttons: message.actions, fillsWidth: false) { button in
                    onTapAction(message, button)
                }
            }
        }
    }

    var body: some View {
        let hiddenAvatars: Set<Int64> = hiddenAvatarIds
        let startsDay: Set<Int64> = startsDayIds
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
                        let showsAvatar: Bool = message.id.map(hiddenAvatars.contains) != true
                        let tail: CGSize? = tail(showsAvatar: showsAvatar && !(message.role == .agent && isWelcome))
                        let timestamp: Date? = showTimestamps ? message.timestamp : nil
                        let buttonsInside: Bool = messageButtonsPosition == .insideMessage
                            && message.type != .image
                            && message.type != .video
                        if let id = message.id, startsDay.contains(id) {
                            DaySeparator(date: message.timestamp)
                        }
                        // The reply's avatar sits level with whatever comes last under
                        // it: the bubble, its buttons, its quick replies or its rating.
                        HStack(alignment: .bottom, spacing: 8) {
                            if message.role == .agent, !isWelcome, assistantMessageAvatar != .none {
                                MessageAvatar(
                                    avatar: assistantMessageAvatar,
                                    background: theme.assistantAvatarBackground,
                                    foreground: theme.onAssistantAvatarBackground
                                )
                                .opacity(showsAvatar ? 1 : 0)
                                .accessibilityIdentifier("yalo-chat-assistant-avatar")
                            }
                            VStack(alignment: isWelcome ? .center : .leading, spacing: 8) {
                                HStack(alignment: .bottom, spacing: 8) {
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
                                        .foregroundStyle(theme.onAssistantMessageBackground)
                                        .accessibilityIdentifier("yalo-chat-agent-message")
                                        .padding(.trailing, isWelcome ? 0 : 48)
                                        .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                                    case (.agent, .video, _):
                                        VideoMessage(message: message, cached: cachedVideo(message), load: loadVideo) {
                                            if showsEnd {
                                                proxy.scrollTo(Self.bottomId, anchor: .bottom)
                                            }
                                        }
                                        .foregroundStyle(theme.onAssistantMessageBackground)
                                        .accessibilityIdentifier("yalo-chat-agent-message")
                                        .padding(.trailing, isWelcome ? 0 : 48)
                                        .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                                    case (.user, _, let note?):
                                        VoiceMessage(
                                            note: note,
                                            playback: playback?.messageId == message.id ? playback : nil,
                                            onToggle: { onToggleVoiceMessage(message) }
                                        )
                                        .userMessageBox(theme, tail: tail, timestamp: timestamp)
                                        .accessibilityIdentifier("yalo-chat-user-message")
                                        .padding(.leading, 48)
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    case (.agent, _, let note?):
                                        VoiceMessage(
                                            note: note,
                                            playback: playback?.messageId == message.id ? playback : nil,
                                            onToggle: { onToggleVoiceMessage(message) }
                                        )
                                        .foregroundStyle(theme.onAssistantMessageBackground)
                                        .assistantMessageBox(theme, tail: tail, timestamp: timestamp) {
                                            if buttonsInside {
                                                insideButtons(of: message)
                                            }
                                        }
                                        .accessibilityIdentifier("yalo-chat-agent-message")
                                        .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                                    case (.user, _, nil):
                                        // Verbatim: asterisks the person typed are asterisks they meant.
                                        Text(verbatim: message.content)
                                            .userMessageBox(theme, tail: tail, timestamp: timestamp)
                                            .accessibilityIdentifier("yalo-chat-user-message")
                                            .padding(.leading, 48)
                                            .frame(maxWidth: .infinity, alignment: .trailing)
                                    case (.agent, _, nil):
                                        Text(markdown(message.content, theme: theme))
                                            .multilineTextAlignment(isWelcome ? .center : .leading)
                                            .foregroundStyle(theme.onAssistantMessageBackground)
                                            .assistantMessageBox(theme, tail: tail, timestamp: timestamp) {
                                                if buttonsInside {
                                                    insideButtons(of: message)
                                                }
                                            }
                                            .accessibilityIdentifier("yalo-chat-agent-message")
                                            .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                                    }
                                    if message.role == .user, userMessageAvatar != .none {
                                        MessageAvatar(
                                            avatar: userMessageAvatar,
                                            background: theme.userAvatarBackground,
                                            foreground: theme.onUserAvatarBackground
                                        )
                                        .opacity(showsAvatar ? 1 : 0)
                                        .accessibilityIdentifier("yalo-chat-user-avatar")
                                    }
                                }
                                if message.role == .agent, !message.actions.isEmpty, !buttonsInside {
                                    MessageButtons(buttons: message.actions) { button in
                                        onTapAction(message, button)
                                    }
                                    .padding(.horizontal, isWelcome ? 24 : 0)
                                    .padding(.trailing, isWelcome ? 0 : 48)
                                }
                                if let id = message.id, id == quickRepliesMessageId {
                                    QuickReplies(replies: message.quickReplies, onTap: onTapButton, vertical: isWelcome)
                                        .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                                }
                                if let id = message.id, rateable.contains(id), message.type == .text, message.wiId != nil {
                                    FeedbackButtons(feedback: message.feedback) { feedback in
                                        onRate(message, feedback)
                                    }
                                    .frame(maxWidth: .infinity, alignment: isWelcome ? .center : .leading)
                                }
                            }
                        }
                    }
                    .transition(.opacity)
                    if isWaitingForReply {
                        // In the same box as a message, so a theme that boxes
                        // messages boxes the indicator too.
                        HStack(alignment: typingIndicatorAvatarPosition == .below ? .bottom : .center, spacing: 8) {
                            if showsWritingAvatar {
                                MessageAvatar(
                                    avatar: assistantMessageAvatar,
                                    background: theme.assistantAvatarBackground,
                                    foreground: theme.onAssistantAvatarBackground
                                )
                                .accessibilityIdentifier("yalo-chat-assistant-avatar")
                            }
                            Group {
                                if typingIndicatorType == .text {
                                    TypingText(text: writingIndicatorText)
                                } else {
                                    TypingIndicator()
                                }
                            }
                            .assistantMessageBox(theme, tail: writingTail, timestamp: nil) {
                                EmptyView()
                            }
                            // The tail already lifts the bubble off the avatar, the way it does on a message.
                            .padding(
                                .bottom,
                                showsWritingAvatar && typingIndicatorAvatarPosition == .below && writingTail == nil ? 32 : 0
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
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
    /// The channel's bubble, with `buttons` under the content and `timestamp` in its bottom trailing corner.
    func assistantMessageBox(
        _ theme: ChatTheme,
        tail: CGSize?,
        timestamp: Date?,
        @ViewBuilder buttons: () -> some View
    ) -> some View {
        let shape: ChatShape = theme.assistantMessageShape.withTail(tail ?? .zero, atTrailing: false)
        return VStack(alignment: .leading, spacing: 12) {
            self
            buttons()
            timestampRoom(timestamp)
        }
        .overlay(alignment: .bottomTrailing) {
            if let timestamp {
                MessageTimestamp(date: timestamp)
            }
        }
        .padding(theme.assistantMessagePadding)
        .padding(.bottom, tail?.height ?? 0)
        .background(theme.assistantMessageBackground, in: shape)
        .overlay(shape.strokeBorder(theme.assistantMessageBorderColor))
    }

    /// The person's bubble, with `timestamp` in its bottom trailing corner.
    func userMessageBox(_ theme: ChatTheme, tail: CGSize?, timestamp: Date?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            self
            timestampRoom(timestamp)
        }
        .overlay(alignment: .bottomTrailing) {
            if let timestamp {
                MessageTimestamp(date: timestamp)
            }
        }
        .padding(theme.userMessagePadding)
        .padding(.bottom, tail?.height ?? 0)
        .foregroundStyle(theme.onUserMessageBackground)
        .background(
            theme.userMessageBackground,
            in: theme.userMessageShape.withTail(tail ?? .zero, atTrailing: true)
        )
    }
}

/// Keeps the room of the timestamp drawn over it, so the content stays leading
/// while the time sits in the trailing corner.
@ViewBuilder
private func timestampRoom(_ timestamp: Date?) -> some View {
    if let timestamp {
        MessageTimestamp(date: timestamp)
            .hidden()
            .accessibilityHidden(true)
    }
}
