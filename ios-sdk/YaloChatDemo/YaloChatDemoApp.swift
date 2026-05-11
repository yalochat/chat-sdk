// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Integration test harness for the Yalo Chat SDK — not production code.
@main
struct YaloChatDemoApp: App {

    init() {
        // TEST 1 — Default theme: uncomment the block below and comment out TEST 2.
        YaloChat.initialize(
            channelName: Credentials.channelName,
            channelId: Credentials.channelId,
            organizationId: Credentials.organizationId,
            environment: Credentials.environment
        )

        // TEST 2 — Custom theme: swap the comment above/below to verify theming works.
        // YaloChat.initialize(
        //     channelName: Credentials.channelName,
        //     channelId: Credentials.channelId,
        //     organizationId: Credentials.organizationId,
        //     environment: Credentials.environment,
        //     theme: ChatTheme(
        //         appBarBackgroundColor: .purple,
        //         userBubbleColor: .green,
        //         sendButtonColor: .orange,
        //         waveformColor: .pink,
        //         quickReplyBorderColor: .orange,
        //         quickReplyTextColor: .orange,
        //         productPriceColor: .red,
        //         expandControlColor: .orange
        //     ),
        //     onShopPressed: { print("shop tapped") },
        //     onCartPressed: { print("cart tapped") }
        // )

        // TEST 3 — Fake repository (no backend required): use useFakeData to verify
        //           all message types render correctly without real credentials.
        // YaloChat.initialize(
        //     channelName: "Demo",
        //     channelId: "fake-channel",
        //     organizationId: "fake-org",
        //     useFakeData: true
        // )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
