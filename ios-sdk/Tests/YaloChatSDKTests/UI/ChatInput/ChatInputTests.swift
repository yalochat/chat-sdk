// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

@MainActor
struct ChatInputTests {
    @Test(arguments: ["", "Hello"])
    func inputRenders(text: String) {
        #expect(renders(ChatInput(text: .constant(text), onSend: {})))
    }

    @Test func inputRendersWithoutTheVoiceButton() {
        #expect(renders(ChatInput(text: .constant(""), onSend: {}, hideVoiceButton: true)))
    }

    @Test func inputRendersWithoutTheAttachmentButton() {
        #expect(renders(ChatInput(text: .constant(""), onSend: {}, hideAttachmentButton: true)))
    }

    @Test func inputRendersARecording() {
        let recording: VoiceRecording = VoiceRecording(elapsed: 65, amplitudes: [0, 0.5, 1])

        #expect(renders(ChatInput(text: .constant(""), onSend: {}, recording: recording)))
    }

    @Test(arguments: ["", "Hello"])
    func inputRendersWithACustomTheme(text: String) {
        let theme: ChatTheme = ChatTheme(
            inputBackground: .white,
            inputShape: ChatShape(radius: 8),
            sendButtonBackground: .pink,
            onSendButtonBackground: .white
        )

        #expect(renders(ChatInput(text: .constant(text), onSend: {}, hideVoiceButton: true).environment(\.chatTheme, theme)))
    }
}
