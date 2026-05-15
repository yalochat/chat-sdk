// Copyright (c) Yalochat, Inc. All rights reserved.

// Shows channel avatar (optional), channel name, animated typing status,
// and optional shop/cart action buttons.

import SwiftUI

struct ChatAppBar: View {

    let channelName: String
    let typingStatusText: String
    let isTyping: Bool
    var onShopPressed: (() -> Void)? = nil
    var onCartPressed: (() -> Void)? = nil

    @Environment(\.chatTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            if let iconImage = theme.chatIconImage {
                iconImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(channelName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(theme.actionIconColor)

                if isTyping && !typingStatusText.isEmpty {
                    Text(typingStatusText)
                        .font(theme.messageFooterFont)
                        .foregroundColor(theme.messageFooterColor)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: isTyping)

            Spacer()

            if let onShop = onShopPressed {
                Button(action: onShop) {
                    Image(systemName: theme.shopIconName)
                        .foregroundColor(theme.actionIconColor)
                }
            }

            if let onCart = onCartPressed {
                Button(action: onCart) {
                    Image(systemName: theme.cartIconName)
                        .foregroundColor(theme.actionIconColor)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(theme.appBarBackgroundColor)
        .shadow(color: Color.black.opacity(0.06), radius: 1, x: 0, y: 1)
    }
}
