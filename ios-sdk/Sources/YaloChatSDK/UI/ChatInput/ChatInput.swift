// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The message input. The button after it records while there is nothing to
/// send and sends once there is, typed text or a recording. With
/// `hideVoiceButton` it is always send, disabled while nothing is typed.
struct ChatInput: View {
    @Binding var text: String
    let onSend: () -> Void
    var hideVoiceButton: Bool = false
    var recording: VoiceRecording?
    var onStartRecording: () -> Void = {}
    var onCancelRecording: () -> Void = {}
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        let canSend: Bool = recording != nil || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let showsSend: Bool = canSend || hideVoiceButton
        HStack(alignment: .bottom, spacing: 8) {
            if let recording {
                VoiceRecordingBar(recording: recording, onCancel: onCancelRecording)
            } else {
                Group {
                    if #available(iOS 16.0, *) {
                        TextField(text: $text, axis: .vertical) {
                            Text("Type a message", bundle: .module)
                        }
                        .lineLimit(1...4)
                    } else {
                        TextField(text: $text) {
                            Text("Type a message", bundle: .module)
                        }
                    }
                }
                .submitLabel(.send)
                .onSubmit(onSend)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .overlay(Capsule().strokeBorder(theme.inputBorderColor))
                .accessibilityIdentifier("yalo-chat-input")
            }
            Button(action: showsSend ? onSend : onStartRecording) {
                Image(systemName: showsSend ? "paperplane.fill" : "mic.fill")
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .foregroundStyle(.white)
                    .background(Color.accentColor, in: Circle())
                    .transition(.scale.combined(with: .opacity))
                    .id(showsSend)
            }
            .disabled(showsSend && !canSend)
            .animation(.easeOut(duration: 0.15), value: showsSend)
            .accessibilityLabel(showsSend ? Text("Send message", bundle: .module) : Text("Record voice message", bundle: .module))
            .accessibilityIdentifier("yalo-chat-send-button")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(theme.onFooterBackground)
        .background(theme.footerBackground)
        .accessibilityIdentifier("yalo-chat-footer")
    }
}

#Preview {
    ChatInput(text: .constant(""), onSend: {})
}
