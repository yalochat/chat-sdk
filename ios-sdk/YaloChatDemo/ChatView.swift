// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct ChatView: View {

    @StateObject private var observable = MessagesObservable()
    @StateObject private var imageObservable = ImageObservable()
    @StateObject private var audioObservable = AudioObservable()

    @Environment(\.scenePhase) private var scenePhase
    // Guards against the double-fire of .onAppear + scenePhase(.active) on initial launch.
    @State private var hasStarted = false

    var body: some View {
        VStack(spacing: 0) {
            ChatAppBar(
                channelName: YaloChatSdk.shared.config?.channelName ?? L10n.defaultChannelName,
                typingStatusText: observable.typingStatusText,
                isTyping: observable.isTyping,
                onShopPressed: YaloChat.onShopPressed,
                onCartPressed: YaloChat.onCartPressed
            )

            MessageList(observable: observable, audioObservable: audioObservable)

            Divider()

            QuickRepliesView(
                quickReplies: observable.quickReplies,
                onChipTap: { label in observable.sendTextMessage(text: label) }
            )

            ChatInput(
                messagesObservable: observable,
                imageObservable: imageObservable,
                audioObservable: audioObservable
            )
        }
        .background(YaloChat.theme.backgroundColor)
        .environment(\.chatTheme, YaloChat.theme)
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            observable.onAppear()
        }
        .onDisappear {
            hasStarted = false
            observable.onDisappear()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                observable.onDisappear()
                // hasStarted intentionally stays true so .active can restart on foreground resume.
            case .active:
                // .onAppear handles the very first start; this handles foreground resume.
                if hasStarted {
                    observable.onAppear()
                }
            default:
                break
            }
        }
    }
}
