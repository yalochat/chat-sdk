// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct ChatView: View {

    @StateObject private var observable = MessagesObservable()
    @StateObject private var imageObservable = ImageObservable()
    @StateObject private var audioObservable = AudioObservable()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MessageList(observable: observable, audioObservable: audioObservable)
                Divider()
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
    }
}
