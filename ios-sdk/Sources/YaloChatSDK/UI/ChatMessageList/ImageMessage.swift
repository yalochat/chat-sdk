// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// A picture in the conversation, with its caption under it when it has one.
/// `cached` is the picture when it has already been read, so a row the list
/// rebuilt after scrolling away is drawn at once. Otherwise `load` is asked,
/// and `onLoaded` is called once the picture it answered with has grown the row.
struct ImageMessage: View {
    /// Room for the spinner while a picture is on its way.
    private static let placeholderSize: CGFloat = 72
    private static let maxWidth: CGFloat = 260
    /// Anything narrower is drawn at this shape rather than running off the screen.
    private static let minAspectRatio: CGFloat = 0.75

    let message: ChatMessage
    let load: (ChatMessage) async -> UIImage?
    let onLoaded: () -> Void
    @State private var picture: UIImage?
    @State private var isLoading: Bool

    init(
        message: ChatMessage,
        cached: UIImage? = nil,
        load: @escaping (ChatMessage) async -> UIImage?,
        onLoaded: @escaping () -> Void = {}
    ) {
        self.message = message
        self.load = load
        self.onLoaded = onLoaded
        _picture = State(initialValue: cached)
        _isLoading = State(initialValue: cached == nil)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let picture {
                let size: CGSize = picture.size
                Color.clear
                    .aspectRatio(
                        size.width > 0 && size.height > 0 ? max(size.width / size.height, Self.minAspectRatio) : 1,
                        contentMode: .fit
                    )
                    .overlay(
                        Image(uiImage: picture)
                            .resizable()
                            .scaledToFill()
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .frame(maxWidth: Self.maxWidth)
                    .accessibilityElement()
                    .accessibilityLabel(Text("Image", bundle: .module))
                    .accessibilityAddTraits(.isImage)
            } else {
                Group {
                    if isLoading {
                        ProgressView()
                    } else {
                        // Nowhere to read it from, which is what a failed download leaves.
                        Image(systemName: "photo")
                            .accessibilityLabel(Text("Image", bundle: .module))
                    }
                }
                .frame(width: Self.placeholderSize, height: Self.placeholderSize)
                .background(Color.secondary.opacity(0.15), in: RoundedRectangle(cornerRadius: 18))
                .accessibilityIdentifier("yalo-chat-image-loading")
            }
            if !message.content.isEmpty {
                switch message.role {
                case .user:
                    Text(verbatim: message.content)
                case .agent:
                    Text(markdown(message.content))
                }
            }
        }
        .accessibilityIdentifier("yalo-chat-image-message")
        .task(id: message.id) {
            guard picture == nil else {
                return
            }
            picture = await load(message)
            isLoading = false
            if picture != nil {
                onLoaded()
            }
        }
    }
}

#Preview {
    ImageMessage(
        message: ChatMessage(role: .user, type: .image, timestamp: Date(), id: 1, image: ImageAttachment()),
        load: { _ in UIImage(systemName: "photo.artframe") }
    )
}
