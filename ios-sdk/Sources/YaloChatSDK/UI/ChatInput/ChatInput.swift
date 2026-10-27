// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The message input. The button after it records while there is nothing to
/// send and sends once there is, typed text or a recording. With
/// `hideVoiceButton` it is always send, disabled while nothing is typed.
///
/// The plus opens the photo picker and sits inside the outline with the field,
/// so the two read as one input. `hideAttachmentButton` leaves it out, and it
/// goes while a recording runs because there is no input to put a picture beside.
struct ChatInput: View {
    @Binding var text: String
    let onSend: () -> Void
    var hideVoiceButton: Bool = false
    var recording: VoiceRecording?
    var onStartRecording: () -> Void = {}
    var onCancelRecording: () -> Void = {}
    var hideAttachmentButton: Bool = false
    var onPickImage: (NSItemProvider) -> Void = { _ in }
    var texts: YaloChatTexts = YaloChatTexts()
    @State private var isPickingImage: Bool = false
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        let canSend: Bool = recording != nil || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let showsSend: Bool = canSend || hideVoiceButton
        let sendIsDisabled: Bool = showsSend && !canSend
        let placeholder: Text = texts.inputPlaceholder.map { custom in Text(verbatim: custom) }
            ?? Text("Type a message", bundle: .module)
        HStack(alignment: .bottom, spacing: 8) {
            if let recording {
                VoiceRecordingBar(recording: recording, onCancel: onCancelRecording)
            } else {
                HStack(alignment: .bottom, spacing: 0) {
                    Group {
                        if #available(iOS 16.0, *) {
                            TextField(text: $text, axis: .vertical) {
                                placeholder
                            }
                            .lineLimit(1...4)
                        } else {
                            TextField(text: $text) {
                                placeholder
                            }
                        }
                    }
                    .submitLabel(.send)
                    .onSubmit(onSend)
                    .padding(.leading, 16)
                    .padding(.trailing, hideAttachmentButton ? 16 : 0)
                    .padding(.vertical, 10)
                    .accessibilityIdentifier("yalo-chat-input")
                    if !hideAttachmentButton {
                        Button {
                            isPickingImage = true
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 20, height: 20)
                                .padding(10)
                                .foregroundStyle(theme.onFooterBackground)
                        }
                        .accessibilityLabel(Text("Send an image", bundle: .module))
                        .accessibilityIdentifier("yalo-chat-attachment-button")
                    }
                }
                .background(theme.inputBackground, in: theme.inputShape)
                .overlay(theme.inputShape.strokeBorder(theme.inputBorderColor))
                .accessibilityIdentifier("yalo-chat-input-box")
            }
            Button(action: showsSend ? onSend : onStartRecording) {
                Image(systemName: showsSend ? "paperplane.fill" : "mic.fill")
                    .frame(width: 20, height: 20)
                    .padding(10)
                    // Faded the way a disabled Material button is, so it reads as off.
                    .foregroundStyle(sendIsDisabled ? theme.onFooterBackground.opacity(0.38) : theme.onSendButtonBackground)
                    .background(sendIsDisabled ? theme.onFooterBackground.opacity(0.12) : theme.sendButtonBackground, in: Circle())
                    .transition(.scale.combined(with: .opacity))
                    .id(showsSend)
            }
            .buttonStyle(.plain)
            .disabled(sendIsDisabled)
            .animation(.easeOut(duration: 0.15), value: showsSend)
            .accessibilityLabel(showsSend ? Text("Send message", bundle: .module) : Text("Record voice message", bundle: .module))
            .accessibilityIdentifier("yalo-chat-send-button")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(theme.onFooterBackground)
        .background(theme.footerBackground)
        .accessibilityIdentifier("yalo-chat-footer")
        .sheet(isPresented: $isPickingImage) {
            ImagePicker { picked in
                isPickingImage = false
                if let picked {
                    onPickImage(picked)
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ChatInput(text: .constant(""), onSend: {})
}
