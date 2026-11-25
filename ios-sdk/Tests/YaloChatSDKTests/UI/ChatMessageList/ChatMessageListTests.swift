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
            ChatMessageList(
                messages: conversation.messages,
                isWaitingForReply: conversation.isWaitingForReply
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

    @Test(arguments: [TypingIndicatorType.threeDots, .text])
    func messageListRendersEachTypingIndicator(type: TypingIndicatorType) {
        #expect(renders(ChatMessageList(messages: [message(1, .user, "Hello")], isWaitingForReply: true, typingIndicatorType: type)))
    }

    @Test func messageListRendersFeedbackUnderTextFromTheChannel() {
        var rated: ChatMessage = message(1, .agent, "Hi")
        rated.wiId = "wi-1"
        rated.feedback = .thumbsUp
        #expect(renders(ChatMessageList(messages: [rated, message(2, .user, "Hello")], showsFeedback: true)))
    }

    @Test func messageListRendersFeedbackInTheThemeColor() {
        var rated: ChatMessage = message(1, .agent, "Hi")
        rated.wiId = "wi-1"
        let list: ChatMessageList = ChatMessageList(messages: [message(2, .user, "Hello"), rated], showsFeedback: true)
        #expect(renders(list.environment(\.chatTheme, ChatTheme(feedbackButtonColor: .gray))))
    }

    @Test func messageListRendersTheTappedPostbackUnderItsMessage() {
        var tapped: ChatMessage = message(1, .agent, "Pick one")
        tapped.buttons = [MessageButton(text: "Menu", kind: .postback, selected: true), MessageButton(text: "Help", kind: .postback)]
        #expect(renders(ChatMessageList(messages: [tapped])))
    }

    @Test func messageListOnlyRatesRepliesAfterTheFirstUserMessage() {
        let messages: [ChatMessage] = [
            message(1, .agent, "Welcome"),
            message(2, .user, "Hello"),
            message(3, .agent, "Sure"),
            message(4, .user, "Thanks"),
            message(5, .agent, "Anytime"),
        ]
        #expect(ChatMessageList(messages: messages).rateableIds == [3, 5])
    }

    @Test func messageListRatesNothingBeforeTheUserSpeaks() {
        #expect(ChatMessageList(messages: [message(1, .agent, "Welcome")]).rateableIds.isEmpty)
    }

    @Test func messageListRendersThemedMessageBoxes() {
        let theme: ChatTheme = ChatTheme(
            userMessageShape: ChatShape(topLeading: 16, topTrailing: 16, bottomLeading: 16),
            assistantMessageBackground: .white,
            assistantMessageShape: ChatShape(radius: 8),
            assistantMessageBorderColor: .gray,
            assistantMessagePadding: EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)
        )
        let note: VoiceNote = VoiceNote(duration: 3, amplitudes: [0.2, 0.8])
        let messages: [ChatMessage] = [
            message(1, .agent, "Hi"),
            message(3, .user, "Hello"),
            ChatMessage(role: .agent, type: .voice, timestamp: Date(), id: 2, voice: note),
        ]

        #expect(renders(ChatMessageList(messages: messages).environment(\.chatTheme, theme)))
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

    @Test func messageListRendersVideoMessages() {
        let messages: [ChatMessage] = [
            ChatMessage(role: .agent, type: .video, timestamp: Date(), id: 1, content: "**Watch**", video: VideoAttachment()),
        ]

        #expect(renders(ChatMessageList(messages: messages, loadVideo: { _ in nil })))
    }

    @Test(arguments: [false, true])
    func messageListRendersTheWelcomeAvatar(isWelcome: Bool) {
        let messages: [ChatMessage] = [message(1, .agent, "Hi")]

        #expect(renders(ChatMessageList(
            messages: messages,
            isWelcome: isWelcome,
            avatar: AnyView(Text(verbatim: "avatar"))
        )))
    }

    @Test(arguments: [(nil, false), (1, false), (1, true)] as [(Int64?, Bool)])
    func messageListRendersButtons(quickRepliesMessageId: Int64?, isWelcome: Bool) {
        let messages: [ChatMessage] = [
            ChatMessage(role: .agent, type: .text, timestamp: Date(), id: 1, content: "Pick one", buttons: [
                MessageButton(text: "Yes"),
                MessageButton(text: "Menu", kind: .postback),
            ]),
        ]

        #expect(renders(ChatMessageList(messages: messages, quickRepliesMessageId: quickRepliesMessageId, isWelcome: isWelcome)))
    }

    @MainActor
    private final class Shrinking: ObservableObject {
        @Published var messages: [ChatMessage] = []
        @Published var below: CGFloat = 0
    }

    private struct ShrinkingHost: View {
        @ObservedObject var conversation: Shrinking

        var body: some View {
            VStack(spacing: 0) {
                ChatMessageList(messages: conversation.messages)
                Color.red.frame(height: conversation.below)
            }
        }
    }

    @Test func theEndStaysInSightWhenTheListGetsShorter() async throws {
        let conversation: Shrinking = Shrinking()
        let window: UIWindow = host(ShrinkingHost(conversation: conversation))
        let list: UIScrollView = try #require(scrollView(in: window))
        conversation.messages = (1...30).map { id in
            message(Int64(id), id.isMultiple(of: 2) ? .user : .agent, "Message \(id)")
        }
        #expect(
            await eventually { list.contentSize.height > list.bounds.height && abs(Self.gapBelow(list)) <= 1 },
            "content \(list.contentSize.height), bounds \(list.bounds.height), gap \(Self.gapBelow(list))"
        )

        conversation.messages.append(message(31, .agent, "Pick one"))
        conversation.below = 120

        #expect(
            await eventually { list.bounds.height < 844 - 100 && abs(Self.gapBelow(list)) <= 1 },
            "bounds \(list.bounds.height), gap \(Self.gapBelow(list))"
        )
        withExtendedLifetime(window) {}
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

    @Test func avatarsShowOnlyOnTheNewestMessageOfEachRunByDefault() {
        let list: ChatMessageList = ChatMessageList(messages: [
            message(1, .agent, "Hi"),
            message(2, .agent, "How can I help?"),
            message(3, .user, "Hello"),
            message(4, .user, "An order"),
            message(5, .agent, "Sure"),
        ])

        #expect(list.hiddenAvatarIds == [1, 3])
    }

    @Test func typingIndicatorTakesTheAvatarFromTheNewestAssistantMessage() {
        let list: ChatMessageList = ChatMessageList(
            messages: [message(1, .user, "Hello"), message(2, .agent, "Hi")],
            isWaitingForReply: true,
            assistantMessageAvatar: .text("YA")
        )

        #expect(list.showsWritingAvatar)
        #expect(list.hiddenAvatarIds == [2])
    }

    @Test func typingIndicatorHasNoAvatarWhenNoneIsSet() {
        let list: ChatMessageList = ChatMessageList(
            messages: [message(1, .user, "Hello"), message(2, .agent, "Hi")],
            isWaitingForReply: true
        )

        #expect(!list.showsWritingAvatar)
        #expect(list.hiddenAvatarIds.isEmpty)
    }

    @Test(arguments: [TypingIndicatorType.threeDots, .text], [TypingIndicatorAvatarPosition.center, .below])
    func messageListRendersTheTypingIndicatorWithAnAvatar(type: TypingIndicatorType, position: TypingIndicatorAvatarPosition) {
        let list: ChatMessageList = ChatMessageList(
            messages: [message(1, .user, "Hello")],
            isWaitingForReply: true,
            assistantMessageAvatar: .text("YA"),
            typingIndicatorType: type,
            typingIndicatorAvatarPosition: position
        )

        #expect(renders(list))
    }

    @Test func avatarsShowOnEveryMessageWhenAsked() {
        let list: ChatMessageList = ChatMessageList(
            messages: [message(1, .agent, "Hi"), message(2, .agent, "How can I help?")],
            avatarDisplay: .everyMessage
        )

        #expect(list.hiddenAvatarIds.isEmpty)
    }

    @Test(arguments: [
        YaloChatMessageAvatar.text("JR"),
        .image(UIImage(systemName: "person")!),
        .none,
    ])
    func messageListRendersAvatarsBesideBothSides(avatar: YaloChatMessageAvatar) {
        let messages: [ChatMessage] = [
            message(1, .agent, "Hi"),
            message(2, .user, "Hello"),
            message(3, .user, "An order"),
        ]
        #expect(renders(ChatMessageList(messages: messages, userMessageAvatar: avatar, assistantMessageAvatar: avatar)))
    }

    @Test func messageAvatarRendersLongText() {
        #expect(renders(MessageAvatar(avatar: .text("Jose Rodrigo"), background: .gray, foreground: .white)))
    }

    @Test func messageListRendersTailsTimestampsAndButtonsInsideTheBubble() {
        var question: ChatMessage = message(2, .agent, "How do you want to look up your ticket?")
        question.buttons = [MessageButton(text: "Ticket", kind: .postback, selected: true), MessageButton(text: "Payroll", kind: .postback)]
        let theme: ChatTheme = ChatTheme(
            postbackShape: .capsule,
            messageTailSize: CGSize(width: 48, height: 24),
            selectedPostbackBorderColor: .pink,
            userMessagePadding: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        )
        let list: ChatMessageList = ChatMessageList(
            messages: [message(1, .user, "Hi"), question],
            userMessageAvatar: .text("JL"),
            assistantMessageAvatar: .text("YA"),
            showTimestamps: true,
            messageButtonsPosition: .insideMessage
        )

        #expect(renders(list.environment(\.chatTheme, theme)))
    }

    @Test func noBubbleGetsATailUnlessTheThemeSetsOne() {
        let list: ChatMessageList = ChatMessageList(messages: [message(1, .user, "Hi")])

        #expect(list.tail(showsAvatar: true) == nil)
    }

    @Test(arguments: [TypingIndicatorAvatarPosition.center, .below])
    func messageListRendersTheTypingIndicatorWithATail(position: TypingIndicatorAvatarPosition) {
        let list: ChatMessageList = ChatMessageList(
            messages: [message(1, .user, "Hello")],
            isWaitingForReply: true,
            assistantMessageAvatar: .text("YA"),
            typingIndicatorType: .text,
            typingIndicatorAvatarPosition: position
        )

        #expect(renders(list.environment(\.chatTheme, ChatTheme(messageTailSize: CGSize(width: 48, height: 24)))))
    }

    @Test func eachDayStartsWithItsDayWhenTimestampsAreOn() {
        let today: Date = Date()
        let yesterday: Date = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let messages: [ChatMessage] = [
            ChatMessage(role: .agent, type: .text, timestamp: yesterday, id: 1, content: "Hi"),
            ChatMessage(role: .user, type: .text, timestamp: yesterday, id: 2, content: "Hello"),
            ChatMessage(role: .agent, type: .text, timestamp: today, id: 3, content: "Welcome back"),
        ]

        #expect(ChatMessageList(messages: messages, showTimestamps: true).startsDayIds == [1, 3])
        #expect(ChatMessageList(messages: messages).startsDayIds.isEmpty)
        #expect(renders(ChatMessageList(messages: messages, showTimestamps: true)))
    }
}
