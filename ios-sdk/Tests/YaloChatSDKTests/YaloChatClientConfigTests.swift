// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

struct YaloChatClientConfigTests {
    @Test(arguments: [
        (nil, "org-1-channel-1-anonymous"),
        ("user-1", "org-1-channel-1-user-1"),
    ] as [(String?, String)])
    func baseSessionIdMatchesTheOtherSDKs(userId: String?, expected: String) {
        let config: YaloChatClientConfig = YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            userId: userId
        )

        #expect(config.baseSessionId == expected)
    }

    @Test func comparesEverythingButTheUserAuthTokenProvider() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")
        let withProvider: YaloChatClientConfig = YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            userAuthTokenProvider: { "token" }
        )
        let otherChannel: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-2", organizationId: "org-1", channelName: "Yalo")

        #expect(config == withProvider)
        #expect(config != otherChannel)
    }

    @Test func showsEverythingUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(!config.hideWatermark)
        #expect(!config.hideVoiceButton)
        #expect(!config.hideAttachmentButton)
        #expect(!config.hideFeedbackButtons)
    }

    @Test func warnsAndOpensWithNoContextUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(config.logLevel == .warn)
        #expect(config.openContext.isEmpty)
    }

    @Test func sharesOneConversationUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(config.sessionMode == .shared)
    }

    @Test func offersQuickRepliesInABarUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(config.quickReplyType == .modal)
    }

    @Test func drawsTheFirstMessageLikeAnyOtherUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(config.welcomeMessageType == .none)
    }

    @Test func keepsTheBuiltInTextsUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(config.texts.inputPlaceholder == nil)
    }

    @Test func comparesTheTexts() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")
        let withTexts: YaloChatClientConfig = YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            texts: YaloChatTexts(inputPlaceholder: "Ask us anything")
        )

        #expect(config != withTexts)
    }
}
