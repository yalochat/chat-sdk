// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// What the message input turns into while a voice note is being recorded:
/// how long it has run, the waveform, and a cross that throws it away.
/// Sending it is the input's own send button.
struct VoiceRecordingBar: View {
    let recording: VoiceRecording
    let onCancel: () -> Void
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        HStack(spacing: 8) {
            Text(verbatim: VoiceWaveform.duration(recording.elapsed))
                .monospacedDigit()
                .frame(minWidth: 40, alignment: .leading)
                .accessibilityIdentifier("yalo-chat-recording-timer")
            VoiceWaveform(amplitudes: recording.amplitudes)
                .frame(height: 24)
            Button(action: onCancel) {
                Image(systemName: "xmark")
                    .frame(width: 20, height: 20)
            }
            .accessibilityLabel(Text("Cancel recording", bundle: .module))
            .accessibilityIdentifier("yalo-chat-cancel-recording")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .overlay(Capsule().strokeBorder(theme.inputBorderColor))
        .accessibilityIdentifier("yalo-chat-recording-bar")
    }
}

#Preview {
    VoiceRecordingBar(
        recording: VoiceRecording(elapsed: 7, amplitudes: (0..<40).map { index in Float(index % 5) / 5 }),
        onCancel: {}
    )
}
