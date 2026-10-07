// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

@MainActor
struct ChatTests {
    @Test(arguments: [false, true])
    func chatRenders(hideWatermark: Bool) {
        let client: YaloChatClient = YaloChatClient(config: YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            hideWatermark: hideWatermark
        ))

        #expect(renders(Chat(client: client)))
    }

    @Test func chatRendersWithACustomTheme() {
        let client: YaloChatClient = YaloChatClient(config: YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo"
        ))
        let theme: ChatTheme = ChatTheme(
            background: .black,
            headerBackground: .indigo,
            onHeaderBackground: .white,
            agentMessageBackground: .gray
        )

        #expect(renders(Chat(client: client, theme: theme)))
    }
}
