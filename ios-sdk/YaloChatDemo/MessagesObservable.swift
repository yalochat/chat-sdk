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
                // DB returns messages ORDER BY id ASC — correct receipt order.
                // Do NOT re-sort by timestamp: server timestamps have only second
                // precision, so bot messages sent in the same second as a user message
                // would sort before it despite arriving later.
                #if DEBUG
                Self.log.debug("messages update: \(messages.count) total")
                for msg in messages {
                    Self.log.debug("  [\(String(describing: msg.role))] [\(String(describing: msg.type))] id=\(msg.id?.int64Value ?? -1) ts=\(msg.timestamp)")
                }
                #endif
                self?.messages = messages
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
        let text = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        Self.log.debug("sendMessage: \(text.prefix(60))")
        userMessage = ""
        controller?.sendTextMessage(text: text)
    }

    func sendTextMessage(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        Self.log.debug("sendTextMessage: \(trimmed.prefix(60))")
        controller?.sendTextMessage(text: trimmed)
    }

    func sendImageMessage(fileName: String, mimeType: String) {
        controller?.sendImageMessage(fileName: fileName, mimeType: mimeType)
    }

    func sendVoiceMessage(fileName: String, amplitudes: [Double], durationMs: Int64) {
        controller?.sendVoiceMessage(
            fileName: fileName,
            amplitudes: amplitudes.map { KotlinDouble(value: $0) },
            durationMs: durationMs
        )
    }
}
