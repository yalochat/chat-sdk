// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Integration test harness for the Yalo Chat SDK — not production code.
@main
struct YaloChatDemoApp: App {

    init() {
        YaloChat.initialize(
            channelName: Credentials.channelName,
            channelId: Credentials.channelId,
            organizationId: Credentials.organizationId,
            apiBaseUrl: Credentials.apiBaseUrl
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
