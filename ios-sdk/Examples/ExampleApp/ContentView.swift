import SwiftUI
import YaloChatSDK

struct ContentView: View {
    private let client: YaloChatClient = YaloChatClient(config: YaloChatClientConfig(
        channelId: "your-channel-id",
        organizationId: "your-organization-id",
        channelName: "Yalo"
    ))

    var body: some View {
        Chat(client: client)
    }
}

#Preview {
    ContentView()
}
