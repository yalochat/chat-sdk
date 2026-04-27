// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct ChatView: View {

    @StateObject private var observable = MessagesObservable()
    @StateObject private var imageObservable = ImageObservable()
    @StateObject private var audioObservable = AudioObservable()

    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
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
            .navigationTitle(YaloChatSdk.shared.config?.channelName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear { observable.onAppear() }
        .onDisappear { observable.onDisappear() }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                observable.onDisappear()
            case .active:
                observable.onAppear()
            default:
                break
            }
        }
    }
}
