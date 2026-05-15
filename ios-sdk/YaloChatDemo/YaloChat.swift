// Copyright (c) Yalochat, Inc. All rights reserved.

import ChatSdk

// Swift entry point for the Yalo Chat SDK.
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
        userId: String? = nil,
        theme: ChatTheme = ChatTheme(),
        onShopPressed: (() -> Void)? = nil,
        onCartPressed: (() -> Void)? = nil,
        useFakeData: Bool = false
    ) {
        YaloChat.theme = theme
        YaloChat.onShopPressed = onShopPressed
        YaloChat.onCartPressed = onCartPressed
        let config = YaloChatConfig(
            channelName: channelName,
            channelId: channelId,
            organizationId: organizationId,
            environment: environment,
            userId: userId,
            useFakeRepository: useFakeData
        )
        YaloChatSdk.shared.initialize(config: config)
    }

    public static func stop() {
        YaloChatSdk.shared.stop()
    }
}
