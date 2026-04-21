// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

// Root chat screen. Mirrors Flutter's Chat widget: NavigationView (ChatAppBar) +
// MessageList + ChatInput stacked vertically.
struct ChatView: View {

    @StateObject private var observable = MessagesObservable()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                MessageList(observable: observable)
                Divider()
                ChatInput(observable: observable)
            }
            .navigationTitle(YaloChatSdk.shared.config?.channelName ?? "Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .onAppear { observable.onAppear() }
        .onDisappear { observable.onDisappear() }
    }
}
