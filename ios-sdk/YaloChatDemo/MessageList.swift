// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import ChatSdk

struct MessageList: View {

    @ObservedObject var observable: MessagesObservable
    @ObservedObject var audioObservable: AudioObservable

    @Environment(\.chatTheme) private var theme

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
                                .foregroundColor(theme.messageFooterColor)
                                .padding(.top, 32)
                        }
                    } else {
                        ForEach(Array(observable.messages.enumerated()), id: \.element.stableListId) { _, message in
                            let messageId = message.id?.int64Value
                            MessageItem(
                                message: message,
                                audioObservable: audioObservable,
                                onButtonTap: { label in observable.sendTextMessage(text: label) },
                                onToggleExpand: { id in observable.toggleMessageExpand(messageId: id) },
                                onUpdateQuantity: { id, sku, isSub, qty in
                                    observable.updateProductQuantity(
                                        messageId: id,
                                        productSku: sku,
                                        isSubunit: isSub,
                                        quantity: qty
                                    )
                                },
                                isExpanded: messageId.map { observable.expandedMessageIds.contains($0) } ?? false
                            )
                        }

                    }
                    Color.clear.frame(height: 1).id("bottom")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .onChange(of: observable.messages.count) { _ in
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

// Stable ID derived from wiId (server-assigned) or local id + timestamp fallback.
// Used by ForEach so SwiftUI can reuse existing views instead of rebuilding on
// every messages-array update (prevents VideoPlayer re-creation / flicker).
extension ChatMessage {
    var stableListId: String {
        wiId ?? "\(id?.int64Value ?? timestamp)"
    }
}

