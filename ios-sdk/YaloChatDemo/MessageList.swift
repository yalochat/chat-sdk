// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct MessageList: View {

    @ObservedObject var observable: MessagesObservable
    @ObservedObject var audioObservable: AudioObservable

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if observable.messages.isEmpty {
                        if observable.isLoading {
                            ProgressView()
                                .padding(.top, 32)
                        } else {
                            Text("No messages yet")
                                .foregroundColor(.secondary)
                                .padding(.top, 32)
                        }
                    } else {
                        ForEach(Array(observable.messages.enumerated()), id: \.offset) { _, message in
                            MessageItem(message: message, audioObservable: audioObservable)
                        }
                    }
                    // Anchor always present so scrollTo("bottom") never targets a missing id.
                    Color.clear.frame(height: 0).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: observable.messages.count) { _ in
                withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
            }
            .onAppear {
                proxy.scrollTo("bottom", anchor: .bottom)
            }
        }
    }
}
