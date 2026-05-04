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

                        if observable.isTyping {
                            TypingIndicatorBubble()
                                .id("typing")
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
            .onChange(of: observable.isTyping) { _ in
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

// Animated three-dot typing bubble — mirrors Flutter ChatTypingMessage.
private struct TypingIndicatorBubble: View {

    @State private var animating = false

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color(.systemGray3))
                        .frame(width: 8, height: 8)
                        .scaleEffect(animating ? 1.0 : 0.5)
                        .animation(
                            .easeInOut(duration: 0.5)
                                .repeatForever()
                                .delay(Double(index) * 0.15),
                            value: animating
                        )
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color(.systemGray5))
            .cornerRadius(16)

            Spacer(minLength: 48)
        }
        .onAppear { animating = true }
        .onDisappear { animating = false }
    }
}
