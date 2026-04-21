// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import ChatSdk
import os

// Mirrors Flutter MessagesBloc: wraps MessagesController and exposes @Published
// properties for SwiftUI. Initialization sequence follows Flutter's dependency
// injection order: SubscribeToMessages → LoadMessages.
class MessagesObservable: ObservableObject {

    @Published var messages: [ChatMessage] = []
    @Published var userMessage: String = ""
    @Published var isLoading: Bool = false

    private static let log = Logger(subsystem: "com.yalo.chat.demo", category: "MessagesObservable")

    private var controller: MessagesController? {
        YaloChatSdk.shared.messagesController
    }

    func onAppear() {
        isLoading = true
        Self.log.debug("onAppear — starting controller")
        controller?.start { [weak self] messages in
            DispatchQueue.main.async {
                let sorted = messages.sorted { $0.timestamp < $1.timestamp }
                Self.log.debug("messages update: \(sorted.count) total")
                for msg in sorted {
                    Self.log.debug("  [\(String(describing: msg.role))] [\(String(describing: msg.type))] id=\(msg.id?.int64Value ?? -1) ts=\(msg.timestamp) content=\(msg.content.prefix(60))")
                }
                self?.messages = sorted
                self?.isLoading = false
            }
        }
        controller?.loadMessages()
    }

    func onDisappear() {
        Self.log.debug("onDisappear — stopping controller")
        controller?.stop()
        isLoading = false
    }

    func sendMessage() {
        let text = userMessage.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        Self.log.debug("sendMessage: \(text.prefix(60))")
        userMessage = ""
        controller?.sendTextMessage(text: text)
    }
}

