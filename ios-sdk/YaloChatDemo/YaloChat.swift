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
//       environment: .staging,
//       theme: ChatTheme(sendButtonColor: .purple),
//       onShopPressed: { print("shop tapped") }
//   )
public final class YaloChat {

    private init() {}

    private(set) static var theme: ChatTheme = ChatTheme()
    private(set) static var onShopPressed: (() -> Void)? = nil
    private(set) static var onCartPressed: (() -> Void)? = nil

    public static func initialize(
        channelName: String,
        channelId: String,
        organizationId: String,
        environment: YaloChatEnvironment = .production,
        theme: ChatTheme = ChatTheme(),
        onShopPressed: (() -> Void)? = nil,
        onCartPressed: (() -> Void)? = nil
    ) {
        YaloChat.theme = theme
        YaloChat.onShopPressed = onShopPressed
        YaloChat.onCartPressed = onCartPressed
        let config = YaloChatConfig(
            channelName: channelName,
            channelId: channelId,
            organizationId: organizationId,
            environment: environment
        )
        YaloChatSdk.shared.initialize(config: config)
    }

    public static func stop() {
        YaloChatSdk.shared.stop()
    }
}
