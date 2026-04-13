// Copyright (c) Yalochat, Inc. All rights reserved.

import ChatSdk

// Swift entry point for the Yalo Chat SDK.
// Mirrors Flutter's YaloChatClient and Android's YaloChat.init() so integrating teams
// use the same credential names across all platforms.
//
// Usage:
//   YaloChat.initialize(
//       channelName: "My Channel",
//       channelId: "your-channel-id",
//       organizationId: "your-org-id",
//       apiBaseUrl: "https://api-staging2.yalochat.com/public-api-gateway/v1/channels"
//   )
public final class YaloChat {

    private init() {}

    public static func initialize(
        channelName: String,
        channelId: String,
        organizationId: String,
        apiBaseUrl: String
    ) {
        let config = YaloChatConfig(
            channelName: channelName,
            channelId: channelId,
            organizationId: organizationId,
            apiBaseUrl: apiBaseUrl,
            useFakeRepository: false
        )
        YaloChatSdk.shared.initialize(config: config)
    }

    public static func stop() {
        YaloChatSdk.shared.stop()
    }
}
