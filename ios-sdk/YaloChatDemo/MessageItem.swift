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
                .foregroundColor(.red)
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
                .foregroundColor(isUser ? .white : .primary)
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
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
        }
    }

    @ViewBuilder
    private var imageContent: some View {
        if let path = message.fileName {
            LocalFileImage(path: path, fallbackColor: bubbleColor)
        } else {
            Label("Image unavailable", systemImage: "photo")
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
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
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            if !message.content.isEmpty {
                Text(message.content)
                    .foregroundColor(.primary)
            }
            if let footer = message.footer, !footer.isEmpty {
                Text(footer)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            let labels = message.buttons.compactMap { $0 as? String }
            if !labels.isEmpty {
                VStack(spacing: 6) {
                    ForEach(labels, id: \.self) { label in
                        Button(action: { onButtonTap(label) }) {
                            Text(label)
                                .font(.subheadline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.accentColor, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
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
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            if !message.content.isEmpty {
                Text(message.content)
                    .foregroundColor(.primary)
            }
            if let footer = message.footer, !footer.isEmpty {
                Text(footer)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            let buttons = message.ctaButtons.compactMap { $0 as? CtaButton }
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
                                Image(systemName: "arrow.up.right")
                                    .font(.caption)
                            }
                            .padding(.vertical, 8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.accentColor, lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
                .padding(.top, 4)
            }
        }
    }

    @ViewBuilder
    private var videoContent: some View {
        if let path = message.fileName {
            VideoPlayer(player: AVPlayer(url: URL(fileURLWithPath: path)))
                .frame(maxWidth: 240, minHeight: 160, maxHeight: 180)
        } else {
            Label("Video unavailable", systemImage: "video")
                .foregroundColor(isUser ? .white.opacity(0.8) : .secondary)
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
                    .foregroundColor(isUser ? .white : .accentColor)
            }
            .disabled(message.fileName == nil || messageId == nil)

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
        let raw = message.amplitudes.map { $0.doubleValue }
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
