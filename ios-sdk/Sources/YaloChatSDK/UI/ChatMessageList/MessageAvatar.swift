// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The circle beside a message, with a picture or a couple of letters in it.
struct MessageAvatar: View {
    @Environment(\.chatTheme) private var theme: ChatTheme
    let avatar: YaloChatMessageAvatar
    let background: Color
    let foreground: Color

    var body: some View {
        ZStack {
            background
            switch avatar {
            case .image(let image):
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            case .text(let text):
                Text(verbatim: String(text.prefix(2)))
                    .font(theme.font(.caption).weight(.semibold))
                    .foregroundStyle(foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            case .none:
                EmptyView()
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}
