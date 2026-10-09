// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation
import Testing
@testable import YaloChatSDK

@MainActor
struct ChatTests {
    private func chat(
        hideWatermark: Bool = false,
        hideVoiceButton: Bool = false,
        hideAttachmentButton: Bool = false,
        theme: ChatTheme = ChatTheme(),
        onBack: (() -> Void)? = nil
    ) -> Chat {
        let client: YaloChatClient = YaloChatClient(config: YaloChatClientConfig(
            channelId: "channel-1",
            organizationId: "org-1",
            channelName: "Yalo",
            hideWatermark: hideWatermark,
            hideVoiceButton: hideVoiceButton,
            hideAttachmentButton: hideAttachmentButton
        ))
        // Kept off the network and the device storage.
        let viewModel: ChatViewModel = ChatViewModel(
            chatMessages: ChatMessageDatabaseService(fileURL: nil),
            yaloMessages: FakeYaloMessageRepository(),
            voice: VoiceRepositoryLocal(
                recorder: FakeVoiceRecorder(),
                player: FakeVoicePlayer(),
                directory: FileManager.default.temporaryDirectory
            ),
            media: MediaRepository(service: FakeYaloMediaService(), tokens: TokenRepository(auth: CountingAuthService())),
            images: ImageDeviceService(directory: FileManager.default.temporaryDirectory),
            tokens: TokenRepository(auth: CountingAuthService()),
            sessionId: client.config.baseSessionId,
            ephemeralDirectory: FileManager.default.temporaryDirectory
                .appendingPathComponent("yalo-chat-tests-\(UUID().uuidString)", isDirectory: true),
            run: ChatViewModel.Run()
        )
        return Chat(client: client, theme: theme, onBack: onBack, viewModel: viewModel)
    }

    @Test(arguments: [false, true])
    func chatRenders(hideWatermark: Bool) {
        #expect(renders(chat(hideWatermark: hideWatermark)))
    }

    @Test func chatRendersWithoutTheVoiceButton() {
        #expect(renders(chat(hideVoiceButton: true)))
    }

    @Test func chatRendersWithoutTheAttachmentButton() {
        #expect(renders(chat(hideAttachmentButton: true)))
    }

    @Test func chatRendersWithABackButton() {
        #expect(renders(chat(onBack: {})))
    }

    @Test func chatRendersWithACustomTheme() {
        let theme: ChatTheme = ChatTheme(
            background: .black,
            headerBackground: .indigo,
            onHeaderBackground: .white,
            agentMessageBackground: .gray
        )

        #expect(renders(chat(theme: theme)))
    }
}
