// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import ChatSdk

// Mirrors Flutter MessagesBloc: wraps MessagesController and exposes @Published
// properties for SwiftUI. Initialization sequence follows Flutter's dependency
// injection order: SubscribeToMessages → LoadMessages.
class MessagesObservable: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var userMessage: String = ""
    @Published var isLoading: Bool = false

    private var controller: MessagesController? {
        YaloChatSdk.shared.messagesController
    }

    // Called from ChatView.onAppear — mirrors Flutter bloc initialization.
    func onAppear() {
        isLoading = true
        // Start sync + observe local DB (mirrors ChatSubscribeToMessages).
        controller?.start { [weak self] messages in
            DispatchQueue.main.async {
                self?.messages = messages.sorted { $0.timestamp < $1.timestamp }
                self?.isLoading = false
            }
        }
        // One-shot local DB read (mirrors ChatLoadMessages).
        controller?.loadMessages()
    }

    // Called from ChatView.onDisappear — stops polling to avoid background work.
    func onDisappear() {
        controller?.stop()
        isLoading = false
    }

    // Mirrors Flutter ChatSendTextMessage: validates, clears input, sends optimistically.
    func sendMessage() {
        let text = userMessage.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        userMessage = ""
        controller?.sendTextMessage(text: text)
    }
}
