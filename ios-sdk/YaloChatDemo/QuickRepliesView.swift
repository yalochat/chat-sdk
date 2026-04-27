// Copyright (c) Yalochat, Inc. All rights reserved.

// Port of android-sdk QuickReplies.kt + QuickReplyChip.kt.
// Flutter renders chips above ChatInput via an Overlay; here we place QuickRepliesView
// directly above ChatInput in ChatView's VStack — same visual result without Overlay.

import SwiftUI

struct QuickRepliesView: View {

    let quickReplies: [String]
    var onChipTap: (String) -> Void = { _ in }

    var body: some View {
        if !quickReplies.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(quickReplies, id: \.self) { reply in
                        QuickReplyChip(text: reply, onTap: { onChipTap(reply) })
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
        }
    }
}

private struct QuickReplyChip: View {

    let text: String
    var onTap: () -> Void = {}

    var body: some View {
        Button(action: onTap) {
            Text(text)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.accentColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .foregroundColor(.accentColor)
        .frame(maxWidth: UIScreen.main.bounds.width * 0.5)
    }
}
