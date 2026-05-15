// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

// Active recording overlay shown in place of the normal ChatInput row.
struct WaveformRecorder: View {

    @ObservedObject var audioObservable: AudioObservable
    // Called with (fileName, amplitudes, durationMs) when the user taps send.
    let onSend: (String, [Double], Int64) -> Void

    @Environment(\.chatTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Button(action: audioObservable.cancelRecording) {
                Image(systemName: theme.cancelRecordingIconName)
                    .foregroundColor(theme.cancelRecordingIconColor)
                    .font(.title2)
            }

            Text(audioObservable.durationText)
                .monospacedDigit()
                .foregroundColor(theme.timerColor)
                .frame(width: 48, alignment: .leading)

            WaveformView(amplitudes: audioObservable.recordingAmplitudes, color: theme.waveformColor)
                .frame(height: 32)

            Button {
                if let data = audioObservable.stopRecording() {
                    onSend(data.fileName, data.amplitudes, data.durationMs)
                }
            } label: {
                Image(systemName: theme.stopRecordingIconName)
                    .foregroundColor(theme.sendButtonIconColor)
                    .font(.title2)
                    .padding(6)
                    .background(theme.sendButtonColor)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
