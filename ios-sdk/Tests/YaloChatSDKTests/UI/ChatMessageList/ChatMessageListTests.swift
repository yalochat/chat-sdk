// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import SwiftUI
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatMessageListTests {
    @MainActor
    private final class Conversation: ObservableObject {
        @Published var messages: [ChatMessage] = []
        @Published var isWaitingForReply: Bool = false
    }

    private struct Host: View {
        @ObservedObject var conversation: Conversation

        var body: some View {
            ChatMessageList(messages: conversation.messages, isWaitingForReply: conversation.isWaitingForReply)
        }
    }

    private func message(_ id: Int64, _ role: ChatMessage.Role, _ content: String) -> ChatMessage {
        ChatMessage(role: role, type: .text, timestamp: Date(), id: id, content: content)
    }

    private func scrollView(in view: UIView) -> UIScrollView? {
        if let scrollView = view as? UIScrollView {
            return scrollView
        }
        return view.subviews.lazy.compactMap { subview in
            scrollView(in: subview)
        }.first
    }

    @Test(arguments: [false, true])
    func messageListRendersUserAndAgentMessages(isWaitingForReply: Bool) {
        let messages: [ChatMessage] = [
            message(1, .agent, "**Hi**\n\n- Orders"),
            message(2, .user, "Hello"),
        ]
        #expect(renders(ChatMessageList(messages: messages, isWaitingForReply: isWaitingForReply)))
    }

    @Test func aLongReplyLeavesTheListScrolledToTheVeryEnd() async throws {
        let conversation: Conversation = Conversation()
        conversation.messages = (1...30).map { id in
            message(Int64(id), id.isMultiple(of: 2) ? .user : .agent, "Message \(id)")
        }
        let controller: UIHostingController = UIHostingController(rootView: Host(conversation: conversation))
        let window: UIWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = controller
        window.makeKeyAndVisible()
        controller.view.layoutIfNeeded()
        let list: UIScrollView = try #require(scrollView(in: controller.view))
        conversation.isWaitingForReply = true

        conversation.isWaitingForReply = false
        let reply: String = (1...12).map { line in
            "Line \(line) of a long reply that wraps across the width of the phone."
        }.joined(separator: "\n\n")
        conversation.messages.append(message(31, .agent, reply))

        #expect(await eventually {
            let gap: CGFloat = list.contentSize.height + list.adjustedContentInset.bottom
                - list.contentOffset.y - list.bounds.height
            return list.contentSize.height > list.bounds.height * 2 && abs(gap) < 1
        })
    }
}
