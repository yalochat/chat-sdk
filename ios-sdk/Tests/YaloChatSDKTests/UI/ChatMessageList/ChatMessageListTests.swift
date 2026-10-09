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
        var loadImage: (ChatMessage) async -> UIImage? = { _ in nil }

        var body: some View {
            ChatMessageList(
                messages: conversation.messages,
                isWaitingForReply: conversation.isWaitingForReply,
                loadImage: loadImage
            )
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

    @Test(arguments: [nil, VoicePlayback(messageId: 1, position: 1, duration: 3, isPlaying: true)])
    func messageListRendersVoiceMessages(playback: VoicePlayback?) {
        let note: VoiceNote = VoiceNote(duration: 3, amplitudes: [0.2, 0.8])
        let messages: [ChatMessage] = [
            ChatMessage(role: .agent, type: .voice, timestamp: Date(), id: 1, voice: note),
            ChatMessage(role: .user, type: .voice, timestamp: Date(), id: 2, voice: note),
            // Named a voice message but sent nothing to play.
            ChatMessage(role: .agent, type: .voice, timestamp: Date(), id: 3),
        ]

        #expect(renders(ChatMessageList(messages: messages, playback: playback)))
    }

    @Test func messageListRendersImageMessages() {
        let messages: [ChatMessage] = [
            ChatMessage(role: .agent, type: .image, timestamp: Date(), id: 1, content: "**Look**", image: ImageAttachment()),
            ChatMessage(role: .user, type: .image, timestamp: Date(), id: 2, image: ImageAttachment()),
        ]

        #expect(renders(ChatMessageList(messages: messages, loadImage: { _ in nil })))
    }

    private static func gapBelow(_ list: UIScrollView) -> CGFloat {
        list.contentSize.height + list.adjustedContentInset.bottom - list.contentOffset.y - list.bounds.height
    }

    /// The window has to outlive the call, or the list stops being drawn.
    private func host(_ view: some View) -> UIWindow {
        let window: UIWindow = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))
        window.rootViewController = UIHostingController(rootView: view)
        window.makeKeyAndVisible()
        window.layoutIfNeeded()
        return window
    }

    @Test func aChatOpensAtTheVeryEnd() async throws {
        let messages: [ChatMessage] = (1...40).map { id in
            message(Int64(id), id.isMultiple(of: 2) ? .user : .agent, String(repeating: "Message \(id) wraps across the width. ", count: id % 5 + 1))
        }
        let conversation: Conversation = Conversation()
        let window: UIWindow = host(Host(conversation: conversation))
        let list: UIScrollView = try #require(scrollView(in: window))
        // Stored messages arrive once the list is already on screen.
        conversation.messages = messages

        #expect(
            await eventually { list.contentSize.height > list.bounds.height * 2 && abs(Self.gapBelow(list)) < 1 },
            "content \(list.contentSize.height), offset \(list.contentOffset.y), bounds \(list.bounds.height), gap \(Self.gapBelow(list))"
        )
        withExtendedLifetime(window) {}
    }

    @Test func aChatOpensAtTheVeryEndOncePicturesHaveLoaded() async throws {
        let picture: UIImage = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 400)).image { context in
            context.fill(CGRect(x: 0, y: 0, width: 300, height: 400))
        }
        let messages: [ChatMessage] = (1...20).map { id in
            id.isMultiple(of: 3)
                ? ChatMessage(role: .user, type: .image, timestamp: Date(), id: Int64(id), image: ImageAttachment())
                : message(Int64(id), id.isMultiple(of: 2) ? .user : .agent, "Message \(id)")
        }
        let loaded: Recorded<Int64?> = Recorded()
        let conversation: Conversation = Conversation()
        let window: UIWindow = host(Host(conversation: conversation, loadImage: { message in
            try? await Task.sleep(nanoseconds: 100_000_000)
            loaded.append(message.id)
            return picture
        }))
        let list: UIScrollView = try #require(scrollView(in: window))
        // Stored messages arrive once the list is already on screen.
        conversation.messages = messages
        #expect(await eventually { !loaded.values.isEmpty })
        try await Task.sleep(nanoseconds: 300_000_000)

        #expect(
            await eventually { list.contentSize.height > list.bounds.height * 2 && abs(Self.gapBelow(list)) < 1 },
            "content \(list.contentSize.height), offset \(list.contentOffset.y), bounds \(list.bounds.height), gap \(Self.gapBelow(list))"
        )
        withExtendedLifetime(window) {}
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
        }, "content \(list.contentSize.height), offset \(list.contentOffset.y), bounds \(list.bounds.height), gap \(Self.gapBelow(list))")
    }
}
