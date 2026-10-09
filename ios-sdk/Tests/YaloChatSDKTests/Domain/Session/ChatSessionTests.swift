// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

struct ChatSessionTests {
    private func config(
        userId: String? = "user-1",
        openContext: [String: String] = [:],
        sessionMode: SessionMode
    ) -> YaloChatClientConfig {
        YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            userId: userId,
            openContext: openContext,
            sessionMode: sessionMode
        )
    }

    @Test func sharedIsTheSameConversationWhateverTheContext() {
        let session: ChatSession = ChatSession(config: config(openContext: ["sku": "1"], sessionMode: .shared))

        #expect(session == ChatSession(config: config(sessionMode: .shared)))
        #expect(session.id == "org-1-channel-1-user-1")
        #expect(session.authUserId == "user-1")
    }

    @Test func perContextMatchesTheWebSDK() {
        let session: ChatSession = ChatSession(config: config(
            openContext: ["source": "product-page", "sku": "37549996"],
            sessionMode: .perContext
        ))

        // The hash of {"sku":"37549996","source":"product-page"}.
        #expect(session.id == "org-1-channel-1-user-1-13rbbtq")
        #expect(session.authUserId == "user-1-13rbbtq")
    }

    @Test func perContextEscapesTheContextLikeJSON() {
        let session: ChatSession = ChatSession(config: config(
            openContext: ["emoji": "ñ é 漢字"],
            sessionMode: .perContext
        ))

        #expect(session.id.hasSuffix("-tyxmh7"))
    }

    @Test func perContextGivesEachContextItsOwnConversation() {
        let first: ChatSession = ChatSession(config: config(openContext: ["sku": "1"], sessionMode: .perContext))
        let second: ChatSession = ChatSession(config: config(openContext: ["sku": "2"], sessionMode: .perContext))

        #expect(first != second)
        #expect(first == ChatSession(config: config(openContext: ["sku": "1"], sessionMode: .perContext)))
    }

    @Test func perContextWithNoContextIsShared() {
        let session: ChatSession = ChatSession(config: config(sessionMode: .perContext))

        #expect(session == ChatSession(config: config(sessionMode: .shared)))
    }

    @Test func ephemeralCarriesItsOwnId() {
        let session: ChatSession = ChatSession(config: config(sessionMode: .ephemeral), ephemeralId: "visit-1")

        #expect(session.id == "org-1-channel-1-user-1-visit-1")
        #expect(session.authUserId == "user-1-visit-1")
    }

    @Test func ephemeralIsANewConversationEveryTime() {
        #expect(ChatSession(config: config(sessionMode: .ephemeral)) != ChatSession(config: config(sessionMode: .ephemeral)))
    }

    @Test(arguments: [SessionMode.shared, .perContext, .ephemeral])
    func anAnonymousPersonIsLeftForTheBackendToName(sessionMode: SessionMode) {
        let session: ChatSession = ChatSession(
            config: config(userId: nil, openContext: ["sku": "1"], sessionMode: sessionMode)
        )

        #expect(session.authUserId == nil)
        #expect(session.id.hasPrefix("org-1-channel-1-anonymous"))
    }

    @Test func controlCharactersAreEscapedLikeJSON() {
        let context: [String: String] = ["text": "\"\\\u{08}\u{0C}\n\r\t\u{01}"]
        let expected: String = xxhash32(#"{"text":"\"\\\b\f\n\r\t\u0001"}"#)

        #expect(ChatSession(config: config(openContext: context, sessionMode: .perContext)).id.hasSuffix("-\(expected)"))
    }
}
