// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// A video in the conversation: its first frame with a play button and its
/// length, and its caption under it when it has one. Tapping it plays it full
/// screen. `cached` is the video when it has already been read, otherwise
/// `load` is asked, and `onLoaded` is called once it has grown the row.
struct VideoMessage: View {
    @Environment(\.chatTheme) private var theme: ChatTheme
    private static let placeholderSize: CGFloat = 72
    private static let maxWidth: CGFloat = 260
    private static let minAspectRatio: CGFloat = 0.75

    let message: ChatMessage
    let load: (ChatMessage) async -> VideoPreview?
    let onLoaded: () -> Void
    @State private var preview: VideoPreview?
    @State private var isLoading: Bool
    @State private var isPlaying: Bool = false

    init(
        message: ChatMessage,
        cached: VideoPreview? = nil,
        load: @escaping (ChatMessage) async -> VideoPreview?,
        onLoaded: @escaping () -> Void = {}
    ) {
        self.message = message
        self.load = load
        self.onLoaded = onLoaded
        _preview = State(initialValue: cached)
        _isLoading = State(initialValue: cached == nil)
    }

    /// `seconds` as the player shows it, such as 0:42 or 1:02:05.
    static func length(_ seconds: TimeInterval) -> String {
        let total: Int = Int(seconds.rounded())
        let hours: Int = total / 3_600
        let minutes: Int = total % 3_600 / 60
        let rest: Int = total % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, rest)
        }
        return String(format: "%d:%02d", minutes, rest)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let preview {
                poster(preview)
            } else if isLoading {
                ProgressView()
                    .frame(width: Self.placeholderSize, height: Self.placeholderSize)
                    .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
                    .accessibilityIdentifier("yalo-chat-video-loading")
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "video.slash")
                    Text("This video can't be played", bundle: .module)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityElement(children: .combine)
                .accessibilityIdentifier("yalo-chat-video-failed")
            }
            if !message.content.isEmpty {
                Text(markdown(message.content, theme: theme))
            }
        }
        .accessibilityIdentifier("yalo-chat-video-message")
        .fullScreenCover(isPresented: $isPlaying) {
            if let preview {
                VideoPlayerScreen(file: preview.file)
            }
        }
        .task(id: message.id) {
            guard preview == nil else {
                return
            }
            preview = await load(message)
            isLoading = false
            if preview != nil {
                onLoaded()
            }
        }
    }

    private func poster(_ preview: VideoPreview) -> some View {
        let size: CGSize = preview.poster.size
        return Button {
            isPlaying = true
        } label: {
            Color.clear
                .aspectRatio(
                    size.width > 0 && size.height > 0 ? max(size.width / size.height, Self.minAspectRatio) : 1,
                    contentMode: .fit
                )
                .overlay(
                    Image(uiImage: preview.poster)
                        .resizable()
                        .scaledToFill()
                )
                .overlay(
                    Image(systemName: "play.fill")
                        .font(theme.font(.title2))
                        .foregroundStyle(.white)
                        .frame(width: 52, height: 52)
                        .background(Color.black.opacity(0.5), in: Circle())
                )
                .overlay(alignment: .bottomTrailing) {
                    if preview.duration > 0 {
                        Text(verbatim: Self.length(preview.duration))
                            .font(theme.font(.caption).monospacedDigit())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.5), in: Capsule())
                            .padding(8)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .frame(maxWidth: Self.maxWidth)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Play video", bundle: .module))
        .accessibilityIdentifier("yalo-chat-video-play")
    }
}

#Preview {
    VideoMessage(
        message: ChatMessage(role: .agent, type: .video, timestamp: Date(), id: 1, content: "How to set it up"),
        cached: VideoPreview(
            file: URL(fileURLWithPath: "/dev/null"),
            poster: UIImage(systemName: "photo.artframe") ?? UIImage(),
            duration: 42
        ),
        load: { _ in nil }
    )
}
