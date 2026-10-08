// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The chat screen: a header, the conversation and the message input.
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
            ChatMessageList(messages: viewModel.messages, isWaitingForReply: viewModel.isWaitingForReply)
            ChatInput(text: $viewModel.draft, onSend: {
                Task {
                    await viewModel.send()
                }
            })
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
