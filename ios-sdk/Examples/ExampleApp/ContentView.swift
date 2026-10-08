// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import YaloChatSDK

/// A host app with nothing in it but a button that opens the chat.
///
/// The chat slides in over the page and covers it while open. The header's
/// back button closes it again, which is why `Chat` is given an `onBack`.
struct ContentView: View {
    private let client: YaloChatClient = YaloChatClient(config: YaloChatClientConfig(
        channelId: "your-channel-id",
        organizationId: "your-organization-id",
        channelName: "Yalo"
    ))

    @State private var chatIsOpen: Bool = false

    var body: some View {
        ZStack {
            Text("Example app")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay(alignment: .bottomTrailing) {
                    if !chatIsOpen {
                        Button("Open chat") {
                            chatIsOpen = true
                        }
                        .buttonStyle(.glassProminent)
                        .controlSize(.large)
                        .padding(16)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            // Trailing follows the reading direction, so the chat enters from
            // the right in English and from the left in Arabic.
            if chatIsOpen {
                Chat(client: client, onBack: {
                    chatIsOpen = false
                })
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut, value: chatIsOpen)
    }
}

#Preview {
    ContentView()
}
