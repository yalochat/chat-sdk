// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

struct YaloChatClientConfigTests {
    @Test(arguments: [
        (nil, "org-1-channel-1-anonymous"),
        ("user-1", "org-1-channel-1-user-1"),
    ] as [(String?, String)])
    func sessionIdMatchesTheOtherSDKs(userId: String?, expected: String) {
        let config: YaloChatClientConfig = YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            userId: userId
        )

        #expect(config.sessionId == expected)
    }

    @Test func showsEverythingUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(!config.hideWatermark)
        #expect(!config.hideVoiceButton)
        #expect(!config.hideAttachmentButton)
    }

    @Test func warnsAndOpensWithNoContextUnlessToldOtherwise() {
        let config: YaloChatClientConfig = YaloChatClientConfig(channelId: "channel-1", organizationId: "org-1", channelName: "Yalo")

        #expect(config.logLevel == .warn)
        #expect(config.openContext.isEmpty)
    }
}
