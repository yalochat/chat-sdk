// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI

struct ChatHeader: View {
    let title: String
    var status: String? = nil
    var hideWatermark: Bool = false
    var onBack: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if let onBack {
                Button(action: onBack) {
                    Image(systemName: "chevron.backward")
                        .font(.title3)
                }
                .accessibilityLabel(Text("Back", bundle: .module))
                .accessibilityIdentifier("yalo-chat-back-button")
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .accessibilityAddTraits(.isHeader)
                if let status {
                    Text(status)
                        .font(.caption)
                        .lineLimit(1)
                        .accessibilityIdentifier("yalo-chat-status")
                }
                if !hideWatermark {
                    Text("By \(Text(verbatim: "Yalo").bold())", bundle: .module)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("yalo-chat-watermark")
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground))
        .accessibilityIdentifier("yalo-chat-header")
    }
}

#Preview {
    VStack {
        ChatHeader(title: "Yalo", status: "Online", onBack: {})
        ChatHeader(title: "Yalo", hideWatermark: true)
    }
}
