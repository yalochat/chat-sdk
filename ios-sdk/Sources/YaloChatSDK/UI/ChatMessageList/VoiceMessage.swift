// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// A voice note in the conversation: play or pause it, its shape, and how long
/// it runs. While it plays the time says how far in it is.
struct VoiceMessage: View {
    let note: VoiceNote
    /// Only when it is this note's.
    let playback: VoicePlayback?
    let onToggle: () -> Void

    var body: some View {
        let isPlaying: Bool = playback?.isPlaying == true
        // A note the channel sent knows its length before it has been loaded.
        let duration: TimeInterval = playback.map(\.duration).flatMap { $0 > 0 ? $0 : nil } ?? note.duration
        let position: TimeInterval = playback?.position ?? 0
        HStack(spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                    .frame(width: 24, height: 24)
            }
            .accessibilityLabel(isPlaying ? Text("Pause voice message", bundle: .module) : Text("Play voice message", bundle: .module))
            .accessibilityIdentifier("yalo-chat-voice-play-button")
            VoiceWaveform(amplitudes: note.amplitudes, progress: duration > 0 ? position / duration : 0)
                .frame(width: 140, height: 24)
            Text(verbatim: VoiceWaveform.duration(isPlaying ? position : duration))
                .font(.caption)
                .monospacedDigit()
        }
        .accessibilityIdentifier("yalo-chat-voice-message")
    }
}

#Preview {
    VoiceMessage(
        note: VoiceNote(duration: 12, amplitudes: (0..<40).map { index in Float(index % 6) / 6 }),
        playback: VoicePlayback(messageId: 1, position: 4, duration: 12, isPlaying: true),
        onToggle: {}
    )
}
