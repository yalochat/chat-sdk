// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// The buttons a message keeps, stacked one per line. With `fillsWidth` each is
/// the full width of the message, so a long text is never cut short, and
/// without it each is as wide as its text.
///
/// A link opens its address outside the chat and carries an arrow to say so.
/// Every other button, a link with no address included, says its text back to
/// the channel through `onTap`. A selected postback is highlighted.
struct MessageButtons: View {
    let buttons: [MessageButton]
    var fillsWidth: Bool = true
    var onTap: (MessageButton) -> Void = { _ in }
    @Environment(\.chatTheme) private var theme: ChatTheme
    @Environment(\.openURL) private var openURL: OpenURLAction

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Texts can repeat, so a button is told apart by where it sits.
            ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                let url: URL? = button.kind == .link ? button.url.flatMap(URL.init(string:)) : nil
                let isSelected: Bool = button.kind == .postback && button.selected
                Button {
                    if let url {
                        openURL(url)
                    } else {
                        onTap(button)
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(verbatim: button.text)
                            .multilineTextAlignment(.center)
                        if url != nil {
                            Image(systemName: "arrow.forward")
                                .imageScale(.small)
                                .accessibilityIdentifier("yalo-chat-link-icon")
                        }
                    }
                    .font(theme.font(.subheadline).weight(.medium))
                    .frame(maxWidth: fillsWidth ? .infinity : nil)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .foregroundStyle(isSelected ? theme.onSelectedPostbackBackground : theme.onPostbackBackground)
                    .background(
                        isSelected ? theme.selectedPostbackBackground : theme.postbackBackground,
                        in: theme.postbackShape
                    )
                    .overlay(
                        theme.postbackShape.strokeBorder(
                            isSelected
                                ? theme.selectedPostbackBorderColor ?? theme.postbackBorderColor
                                : theme.postbackBorderColor
                        )
                    )
                    .contentShape(theme.postbackShape)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("yalo-chat-message-button")
                .accessibilityAddTraits(isSelected ? .isSelected : [])
            }
        }
    }
}
