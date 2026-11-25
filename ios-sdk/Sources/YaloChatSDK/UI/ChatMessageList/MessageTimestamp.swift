// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

/// When a message was sent, in the device time format.
struct MessageTimestamp: View {
    let date: Date
    @Environment(\.chatTheme) private var theme: ChatTheme

    var body: some View {
        Text(date, style: .time)
            .font(theme.font(.caption))
            .foregroundStyle(theme.timestampColor)
            .accessibilityIdentifier("yalo-chat-message-timestamp")
    }
}
