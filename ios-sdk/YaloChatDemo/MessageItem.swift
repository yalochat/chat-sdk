// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import UIKit
import AVKit
import ChatSdk

struct MessageItem: View {

    let message: ChatMessage
    @ObservedObject var audioObservable: AudioObservable
    var onButtonTap: (String) -> Void = { _ in }
    var onToggleExpand: (Int64) -> Void = { _ in }
    var onUpdateQuantity: (Int64, String, Bool, Double) -> Void = { _, _, _, _ in }
    var isExpanded: Bool = false

    @Environment(\.chatTheme) private var theme

    private var isUser: Bool { message.role === MessageRole.user }

    // Product messages render their own card borders — bypass the bubble HStack layout.
    private var isProductMessage: Bool {
        message.type is MessageType.Product || message.type is MessageType.ProductCarousel
    }

    var body: some View {
        if isProductMessage {
            productMessageRow
        } else {
            HStack(alignment: .bottom, spacing: 4) {
                if isUser {
                    Spacer(minLength: 48)
                    errorIndicator
                    bubble
                } else {
                    bubble
                    Spacer(minLength: 48)
                }
            }
        }
    }

    @ViewBuilder
    private var errorIndicator: some View {
        if isUser && message.status === MessageStatus.error {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(theme.errorColor)
                .font(.caption)
        }
    }

    @ViewBuilder
    private var productMessageRow: some View {
        HStack {
            if let messageId = message.id?.int64Value {
                if message.type is MessageType.Product {
                    ProductListView(
                        message: message,
                        isExpanded: isExpanded,
                        onToggleExpand: { onToggleExpand(messageId) },
                        onUpdateQuantity: { sku, isSub, qty in
                            onUpdateQuantity(messageId, sku, isSub, qty)
                        }
                    )
                } else {
                    ProductCarouselView(
                        message: message,
                        isExpanded: isExpanded,
                        onToggleExpand: { onToggleExpand(messageId) },
                        onUpdateQuantity: { sku, isSub, qty in
                            onUpdateQuantity(messageId, sku, isSub, qty)
                        }
                    )
                }
            }
            Spacer(minLength: 0)
        }
    }

    private var bubble: some View {
        Group {
            if message.type is MessageType.Image {
                imageContent
                    .cornerRadius(16)
            } else if message.type is MessageType.Video {
                videoContent
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
        if message.type is MessageType.Text || message.type is MessageType.QuickReply {
            Text(message.content)
                .font(isUser ? theme.userMessageFont : theme.agentMessageFont)
                .foregroundColor(isUser ? theme.userBubbleTextColor : theme.agentBubbleTextColor)
        } else if message.type is MessageType.Voice {
            voiceContent
        } else if message.type is MessageType.Buttons {
            buttonsContent
        } else if message.type is MessageType.CTA {
            ctaContent
        } else {
            Text("Unsupported message type")
                .font(.caption)
                .italic()
                .foregroundColor(isUser ? theme.userBubbleTextColor.opacity(0.8) : theme.messageFooterColor)
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let path = message.fileName {
            LocalFileImage(path: path, fallbackColor: bubbleColor)
        } else {
            Label("Image unavailable", systemImage: "photo")
                .foregroundColor(isUser ? theme.userBubbleTextColor.opacity(0.8) : theme.messageFooterColor)
                .font(.caption)
                .padding(12)
                .background(bubbleColor)
        }
    }

    @ViewBuilder
    private var buttonsContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header = message.header, !header.isEmpty {
                Text(header)
                    .font(theme.messageHeaderFont)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.agentBubbleTextColor)
            }
            if !message.content.isEmpty {
                Text(message.content)
                    .font(theme.agentMessageFont)
                    .foregroundColor(theme.agentBubbleTextColor)
            }
            if let footer = message.footer, !footer.isEmpty {
                Text(footer)
                    .font(theme.messageFooterFont)
                    .foregroundColor(theme.messageFooterColor)
            }
            let labels = message.buttons
            if !labels.isEmpty {
                VStack(spacing: 6) {
                    ForEach(labels, id: \.self) { label in
                        Button(action: { onButtonTap(label) }) {
                            Text(label)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(theme.buttonsButtonColor)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(theme.buttonsButtonBorderColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(theme.buttonsButtonTextColor)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private var ctaContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let header = message.header, !header.isEmpty {
                Text(header)
                    .font(theme.messageHeaderFont)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.agentBubbleTextColor)
            }
            if !message.content.isEmpty {
                Text(message.content)
                    .font(theme.agentMessageFont)
                    .foregroundColor(theme.agentBubbleTextColor)
            }
            if let footer = message.footer, !footer.isEmpty {
                Text(footer)
                    .font(theme.messageFooterFont)
                    .foregroundColor(theme.messageFooterColor)
            }
            let buttons = message.ctaButtons
            if !buttons.isEmpty {
                VStack(spacing: 6) {
                    ForEach(buttons, id: \.url) { button in
                        Button(action: {
                            if let url = URL(string: button.url) {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Text(button.text)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: theme.ctaArrowIconName)
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                            .background(theme.ctaButtonColor)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(theme.ctaButtonBorderColor, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(theme.ctaButtonTextColor)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private var videoContent: some View {
        if let path = message.fileName {
            StableVideoPlayer(path: path)
        } else {
            Label("Video unavailable", systemImage: "video")
                .foregroundColor(isUser ? theme.userBubbleTextColor.opacity(0.8) : theme.messageFooterColor)
                .font(.caption)
                .padding(12)
                .background(bubbleColor)
        }
    }

    @ViewBuilder
    private var voiceContent: some View {
        let messageId = message.id?.int64Value
        let isPlaying = messageId.map { audioObservable.playingMessageId == $0 } ?? false

        HStack(spacing: 8) {
            Button {
                guard let mid = messageId, let path = message.fileName else { return }
                audioObservable.togglePlayback(messageId: mid, fileName: path)
            } label: {
                Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(isUser ? theme.userBubbleTextColor : theme.waveformColor)
            }
            .disabled(message.fileName == nil || messageId == nil)

            WaveformView(
                amplitudes: resolvedAmplitudes,
                color: isUser ? theme.userBubbleTextColor.opacity(0.7) : theme.waveformColor
            )
            .frame(width: 100, height: 28)

            Text(voiceDuration)
                .monospacedDigit()
                .font(.caption)
                .foregroundColor(isUser ? theme.userBubbleTextColor.opacity(0.8) : theme.messageFooterColor)
        }
    }

    private var resolvedAmplitudes: [Double] {
        let raw = message.amplitudes.map { $0.doubleValue }
        return raw.isEmpty ? Array(repeating: -30.0, count: 48) : raw
    }

    private var voiceDuration: String {
        let ms = message.duration?.int64Value ?? 0
        let s = ms / 1000
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    private var bubbleColor: Color {
        isUser ? theme.userBubbleColor : theme.agentBubbleColor
    }
}

// Holds an AVPlayer in @State so it is created once and survives parent view re-renders.
// Without this, AVPlayer(url:) in the body would recreate the player on every render
// (e.g. when product quantity steppers update the messages array), causing video flicker.
private struct StableVideoPlayer: View {
    let path: String
    @State private var player: AVPlayer?

    var body: some View {
        Group {
            if let player {
                VideoPlayer(player: player)
                    .frame(maxWidth: 240, minHeight: 160, maxHeight: 180)
            } else {
                Color.black
                    .frame(maxWidth: 240, minHeight: 160, maxHeight: 180)
                    .overlay(
                        Image(systemName: "play.circle.fill")
                            .font(.largeTitle)
                            .foregroundColor(.white.opacity(0.7))
                    )
            }
        }
        .onAppear {
            guard player == nil else { return }
            player = AVPlayer(url: URL(fileURLWithPath: path))
        }
    }
}

// Loads an image from a local file path exactly once, off the main thread.
// Avoids calling UIImage(contentsOfFile:) in the SwiftUI body on every render.
private struct LocalFileImage: View {
    let path: String
    let fallbackColor: Color

    @State private var uiImage: UIImage? = nil

    var body: some View {
        Group {
            if let img = uiImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 200, maxHeight: 200)
                    .clipped()
            } else {
                fallbackColor
                    .frame(width: 200, height: 150)
                    .overlay(ProgressView())
            }
        }
        .task(id: path) {
            guard uiImage == nil else { return }
            uiImage = await Task.detached(priority: .userInitiated) {
                UIImage(contentsOfFile: path)
            }.value
        }
    }
}
