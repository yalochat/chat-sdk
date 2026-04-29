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

    // Typing indicator — mirrors Android MessagesViewModel.isSystemTypingMessage / chatStatusText.
    @Published var isTyping: Bool = false
    @Published var typingStatusText: String = ""

    // Quick reply chips derived from the last QuickReply-type agent message.
    // Cleared when the user sends a message; restored when a new QuickReply message arrives.
    @Published var quickReplies: [String] = []

    // In-memory expand state for product list/carousel — never stored in DB.
    @Published var expandedMessageIds: Set<Int64> = []

    private static let log = Logger(subsystem: "com.yalo.chat.demo", category: "MessagesObservable")

    // Tracks the wiId of the QuickReply message that populated the current chip row.
    // Mirrors Android MessagesViewModel.lastQuickReplyMessageWiId guard.
    private var lastQuickReplyWiId: String? = nil

    private var controller: MessagesController? {
        YaloChatSdk.shared.messagesController
    }

    func onAppear() {
        // Only show loading spinner on the very first start (messages list is empty).
        // On foreground-resume the controller restarts but messages are already displayed.
        if messages.isEmpty { isLoading = true }
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
                self?.updateQuickRepliesFromMessages(messages)
            }
        }
        controller?.loadMessages()
        controller?.startEventsObservation(
            onTypingStart: { [weak self] statusText in
                DispatchQueue.main.async {
                    self?.isTyping = true
                    self?.typingStatusText = statusText
                }
            },
            onTypingStop: { [weak self] in
                DispatchQueue.main.async {
                    self?.isTyping = false
                    self?.typingStatusText = ""
                }
            }
        )
    }

    func onDisappear() {
        Self.log.debug("onDisappear — stopping controller")
        controller?.stop()
        isLoading = false
        isTyping = false
        typingStatusText = ""
    }

    func sendMessage() {
        let text = userMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        #if DEBUG
        Self.log.debug("sendMessage: \(text.prefix(60))")
        #endif
        userMessage = ""
        clearQuickReplies()
        controller?.sendTextMessage(text: text)
    }

    func sendTextMessage(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        #if DEBUG
        Self.log.debug("sendTextMessage: \(trimmed.prefix(60))")
        #endif
        clearQuickReplies()
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

    // MARK: - Quick replies

    func clearQuickReplies() {
        quickReplies = []
    }

    // Derives the current chip row from messages, same logic as Android extractQuickReplies().
    // Only updates when a new QuickReply message (different wiId) arrives so that a
    // ClearQuickReplies triggered by user send isn't undone by the next observeMessages emission.
    private func updateQuickRepliesFromMessages(_ messages: [ChatMessage]) {
        let lastQr = messages.last { msg in
            msg.type is MessageType.QuickReply && msg.role === MessageRole.agent
        }
        guard let qrMsg = lastQr else { return }
        let wiId = qrMsg.wiId
        guard wiId != lastQuickReplyWiId else { return }
        lastQuickReplyWiId = wiId
        quickReplies = qrMsg.quickReplies
    }

    // MARK: - Product expand

    func toggleMessageExpand(messageId: Int64) {
        if expandedMessageIds.contains(messageId) {
            expandedMessageIds.remove(messageId)
        } else {
            expandedMessageIds.insert(messageId)
        }
    }

    // MARK: - Product quantity

    func updateProductQuantity(messageId: Int64, productSku: String, isSubunit: Bool, quantity: Double) {
        controller?.updateProductQuantity(
            messageId: messageId,
            productSku: productSku,
            isSubunit: isSubunit,
            quantity: quantity
        )
    }
}
