// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The message input. The button after it records while there is nothing to
/// send and sends once there is, typed text or a recording. With
/// `hideVoiceButton` it is always send, disabled while nothing is typed.
///
/// The plus opens the photo picker and sits inside the outline with the field,
/// so the two read as one input. `hideAttachmentButton` leaves it out, and it
/// goes while a recording runs because there is no input to put a picture beside.
///
/// The field grows with what is typed up to four lines. Past that the text
/// scrolls inside it, and a thin thumb on its trailing edge, in the theme's
/// `inputScrollbarColor` and `inputScrollbarWidth`, shows which part is in view.
struct ChatInput: View {
    @Binding var text: String
    let onSend: () -> Void
    var hideVoiceButton: Bool = false
    var recording: VoiceRecording?
    var onStartRecording: () -> Void = {}
    var onCancelRecording: () -> Void = {}
    var hideAttachmentButton: Bool = false
    var onPickImage: (NSItemProvider) -> Void = { _ in }
    @State private var isPickingImage: Bool = false
    @State private var inputHeight: CGFloat = 0
    @State private var inputScroll: InputScrollMetrics = InputScrollMetrics()
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        let canSend: Bool = recording != nil || !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let showsSend: Bool = canSend || hideVoiceButton
        let sendIsDisabled: Bool = showsSend && !canSend
        HStack(alignment: .bottom, spacing: 8) {
            if let recording {
                VoiceRecordingBar(recording: recording, onCancel: onCancelRecording)
            } else {
                HStack(alignment: .bottom, spacing: 0) {
                    ChatInputTextView(
                        text: $text,
                        height: $inputHeight,
                        metrics: $inputScroll,
                        textColor: UIColor(theme.onFooterBackground),
                        trailingInset: theme.inputScrollbarWidth > 0 ? theme.inputScrollbarWidth + inputScrollbarGap : 0,
                        accessibilityLabel: String(localized: "Type a message", bundle: .module),
                        onSend: onSend
                    )
                    .frame(height: inputHeight > 0 ? inputHeight : laidOutLineHeight(for: .preferredFont(forTextStyle: .body)))
                    .overlay(alignment: .topLeading) {
                        if text.isEmpty {
                            Text("Type a message", bundle: .module)
                                .foregroundStyle(Color(.placeholderText))
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if theme.inputScrollbarWidth > 0, let thumb = scrollbarThumb(metrics: inputScroll) {
                            Capsule()
                                .fill(theme.inputScrollbarColor)
                                .frame(width: theme.inputScrollbarWidth, height: thumb.height)
                                .offset(y: thumb.top)
                                .allowsHitTesting(false)
                                .accessibilityHidden(true)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, hideAttachmentButton ? 16 : 0)
                    .padding(.vertical, 10)
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
