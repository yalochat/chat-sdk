// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The chat screen: a header, the conversation and the message input.
///
/// Voice messages need `NSMicrophoneUsageDescription` in your app's
/// Info.plist. Set `hideVoiceButton` in the client config to leave them out.
///
/// Image messages need no permission: the plus in the message input opens the
/// system photo picker, which hands over only what the person picked. Set
/// `hideAttachmentButton` in the client config to leave the plus out.
public struct Chat: View {
    private let client: YaloChatClient
    private let theme: ChatTheme
    private let onBack: (() -> Void)?
    @StateObject private var viewModel: ChatViewModel
    @Environment(\.scenePhase) private var scenePhase: ScenePhase

    /// - Parameter onBack: Shows a back button in the header that calls it.
    ///   Leave it out when the chat is not something the person closes.
    public init(client: YaloChatClient, theme: ChatTheme = ChatTheme(), onBack: (() -> Void)? = nil) {
        self.init(
            client: client,
            theme: theme,
            onBack: onBack,
            viewModel: ChatDependencies(config: client.config).chatViewModel()
        )
    }

    init(
        client: YaloChatClient,
        theme: ChatTheme,
        onBack: (() -> Void)? = nil,
        viewModel: @autoclosure @escaping () -> ChatViewModel
    ) {
        self.client = client
        self.theme = theme
        self.onBack = onBack
        _viewModel = StateObject(wrappedValue: viewModel())
    }

    public var body: some View {
        VStack(spacing: 0) {
            ChatHeader(
                title: client.config.channelName,
                hideWatermark: client.config.hideWatermark,
                onBack: onBack
            )
            ChatMessageList(
                messages: viewModel.messages,
                isWaitingForReply: viewModel.isWaitingForReply,
                playback: viewModel.playback,
                onToggleVoiceMessage: { message in
                    Task {
                        await viewModel.toggleVoiceMessage(message)
                    }
                },
                loadImage: viewModel.image(of:)
            )
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

#Preview {
    Chat(client: YaloChatClient(config: YaloChatClientConfig(
        channelId: "channel",
        organizationId: "organization",
        channelName: "Yalo"
    )))
}
