// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct ChatInput: View {
    @Binding var text: String
    let onSend: () -> Void
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            Group {
                if #available(iOS 16.0, *) {
                    TextField(text: $text, axis: .vertical) {
                        Text("Type a message", bundle: .module)
                    }
                    .lineLimit(1...4)
                } else {
                    TextField(text: $text) {
                        Text("Type a message", bundle: .module)
                    }
                }
            }
            .submitLabel(.send)
            .onSubmit(onSend)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .overlay(Capsule().strokeBorder(theme.inputBorderColor))
            .accessibilityIdentifier("yalo-chat-input")
            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .frame(width: 20, height: 20)
                    .padding(10)
                    .foregroundStyle(.white)
                    .background(Color.accentColor, in: Circle())
            }
            .accessibilityLabel(Text("Send message", bundle: .module))
            .accessibilityIdentifier("yalo-chat-send-button")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .foregroundStyle(theme.onFooterBackground)
        .background(theme.footerBackground)
        .accessibilityIdentifier("yalo-chat-footer")
    }
}

#Preview {
    ChatInput(text: .constant(""), onSend: {})
}
