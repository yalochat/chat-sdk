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
                        ForEach(Array(observable.messages.enumerated()), id: \.offset) { index, message in
                            MessageItem(
                                message: message,
                                audioObservable: audioObservable,
                                onButtonTap: { label in observable.sendTextMessage(text: label) }
                            )
                            .id(index)
                        }
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: observable.messages.count) { count in
                DispatchQueue.main.async {
                    withAnimation(.linear(duration: 0.15)) {
                        proxy.scrollTo("bottom", anchor: .bottom)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}
