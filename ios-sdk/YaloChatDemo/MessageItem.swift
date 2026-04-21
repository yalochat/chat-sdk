// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import UIKit
import ChatSdk

struct MessageItem: View {

    let message: ChatMessage
    @ObservedObject var audioObservable: AudioObservable

    private var isUser: Bool { message.role === MessageRole.user }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if isUser {
                Spacer(minLength: 48)
                bubble
            } else {
                bubble
                Spacer(minLength: 48)
            }
        }
    }

    private var bubble: some View {
        Group {
            if message.type is MessageType.Image {
                imageContent
                    .cornerRadius(16)
            } else {
                bubbleContent
                    .padding(12)
                    .background(bubbleColor)
                    .cornerRadius(16)
            }
        }
    }

    @ViewBuilder
    private var bubbleContent: some View {
        if message.type is MessageType.Text {
            Text(message.content)
                .foregroundColor(isUser ? .white : .primary)
        } else if message.type is MessageType.Voice {
            voiceContent
        } else {
            Text("Unsupported message type")
                .font(.caption)
                .italic()
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let path = message.fileName, let uiImage = UIImage(contentsOfFile: path) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: 200, maxHeight: 200)
                .clipped()
        } else {
            Label("Image unavailable", systemImage: "photo")
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
                .font(.caption)
                .padding(12)
                .background(bubbleColor)
        }
    }

    @ViewBuilder
    private var voiceContent: some View {
        let messageId = message.id?.int64Value ?? 0
        let isPlaying = audioObservable.playingMessageId == messageId

        HStack(spacing: 8) {
            Button {
                guard let path = message.fileName else { return }
                audioObservable.togglePlayback(messageId: messageId, fileName: path)
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(isUser ? .white : .accentColor)
            }
            .disabled(message.fileName == nil)

            WaveformView(
                amplitudes: resolvedAmplitudes,
                color: isUser ? .white.opacity(0.7) : .accentColor
            )
            .frame(width: 100, height: 28)

            Text(voiceDuration)
                .monospacedDigit()
                .font(.caption)
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
        }
    }

    private var resolvedAmplitudes: [Double] {
        let raw = message.amplitudes.compactMap { ($0 as? NSNumber)?.doubleValue }
        return raw.isEmpty ? Array(repeating: -30.0, count: 48) : raw
    }

    private var voiceDuration: String {
        let ms = message.duration?.int64Value ?? 0
        let s = ms / 1000
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private var bubbleColor: Color {
        isUser ? .accentColor : Color(.systemGray5)
    }
}
