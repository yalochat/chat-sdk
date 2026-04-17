// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

// Mirrors Flutter MessageList (ListView reverse:true).
// Messages are sorted ascending by MessagesObservable so the newest appears at the bottom.
// ScrollViewReader auto-scrolls to the last item when the count changes.
struct MessageList: View {

    @ObservedObject var observable: MessagesObservable

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
                        ForEach(observable.messages, id: \.timestamp) { message in
                            MessageItem(message: message)
                                .id(message.timestamp)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: observable.messages.count) { _ in
                if let last = observable.messages.last {
                    withAnimation {
                        proxy.scrollTo(last.timestamp, anchor: .bottom)
                    }
                }
            }
            .onAppear {
                if let last = observable.messages.last {
                    proxy.scrollTo(last.timestamp, anchor: .bottom)
                }
            }
        }
    }
}
