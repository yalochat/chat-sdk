// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The chat screen: a header, the conversation and the message input.
///
/// Quick replies follow `quickReplyType` in the client config: a bar above the
/// message input, or chips under the message that offered them. Postback and
/// link buttons always stay under their message. A link opens its address
/// outside the chat.
///
/// With `welcomeMessageType` set to `.verticalQuickReplies`, the channel's
/// first message is drawn alone and centered with one quick reply per line
/// until the person sends something. The avatar is drawn centered above it.
///
/// Voice messages need `NSMicrophoneUsageDescription` in your app's
/// Info.plist. Set `hideVoiceButton` in the client config to leave them out.
///
/// Image messages need no permission: the plus in the message input opens the
/// system photo picker, which hands over only what the person picked. Set
/// `hideAttachmentButton` in the client config to leave the plus out.
public struct Chat<Avatar: View>: View {
    private let client: YaloChatClient
    private let theme: ChatTheme
    private let onBack: (() -> Void)?
    private let avatar: Avatar?
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// - Parameters:
    ///   - onBack: Shows a back button in the header that calls it.
    ///     Leave it out when the chat is not something the person closes.
    ///   - avatar: Drawn beside the channel name in the header, and above the
    ///     welcome message. For example an `AsyncImage` of your logo.
    public init(
        client: YaloChatClient,
        theme: ChatTheme = ChatTheme(),
        onBack: (() -> Void)? = nil,
        @ViewBuilder avatar: () -> Avatar
    ) {
        self.init(
            client: client,
            theme: theme,
            onBack: onBack,
            avatar: avatar(),
            viewModel: ChatDependencies(config: client.config).chatViewModel()
        )
    }

    init(
        client: YaloChatClient,
        theme: ChatTheme,
        onBack: (() -> Void)? = nil,
        avatar: Avatar?,
        viewModel: @autoclosure @escaping () -> ChatViewModel
    ) {
        self.client = client
        self.theme = theme
        self.onBack = onBack
        self.avatar = avatar
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        let inline: Bool = client.config.quickReplyType == .inline || viewModel.isWelcome
        VStack(spacing: 0) {
            ChatHeader(
                title: client.config.channelName,
                hideWatermark: client.config.hideWatermark,
                avatar: avatar.map { avatar in AnyView(avatar) },
                onBack: onBack
            )
            ChatMessageList(
                messages: viewModel.messages,
                isWaitingForReply: viewModel.isWaitingForReply,
                quickRepliesMessageId: inline ? viewModel.quickRepliesMessageId : nil,
                isWelcome: viewModel.isWelcome,
                avatar: avatar.map { avatar in AnyView(avatar) },
                onTapButton: { button in
                    Task {
                        await viewModel.tap(button)
                    }
                },
                playback: viewModel.playback,
                onToggleVoiceMessage: { message in
                    Task {
                        await viewModel.toggleVoiceMessage(message)
                    }
                },
                cachedImage: viewModel.cachedImage(of:),
                loadImage: viewModel.image(of:)
            )
            if !inline, !viewModel.quickReplies.isEmpty {
                QuickReplyBar(replies: viewModel.quickReplies) { reply in
                    Task {
                        await viewModel.tap(reply)
                    }
                }
            }
            ChatInput(
                text: $viewModel.draft,
                onSend: {
                    Task {
                        await viewModel.send()
                    }
                },
                hideVoiceButton: client.config.hideVoiceButton,
                recording: viewModel.recording,
                onStartRecording: {
                    Task {
                        await viewModel.startRecording()
                    }
                },
                onCancelRecording: viewModel.cancelRecording,
                hideAttachmentButton: client.config.hideAttachmentButton,
                onPickImage: { picked in
                    Task {
                        await viewModel.sendImage(picked)
                    }
                }
            )
        }
        .background(theme.background)
        .environment(\.chatTheme, theme)
        .task {
            await viewModel.start()
        }
        .onChange(of: scenePhase) { phase in
            viewModel.onScenePhaseChange(phase)
        }
    }
}

public extension Chat where Avatar == EmptyView {
    /// - Parameter onBack: Shows a back button in the header that calls it.
    ///   Leave it out when the chat is not something the person closes.
    init(client: YaloChatClient, theme: ChatTheme = ChatTheme(), onBack: (() -> Void)? = nil) {
        self.init(
            client: client,
            theme: theme,
            onBack: onBack,
            avatar: nil,
            viewModel: ChatDependencies(config: client.config).chatViewModel()
        )
    }
}

#Preview {
    Chat(client: YaloChatClient(config: YaloChatClientConfig(
        channelId: "channel",
        organizationId: "organization",
        channelName: "Yalo"
    )))
}
