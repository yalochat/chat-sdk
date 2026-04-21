// Copyright (c) Yalochat, Inc. All rights reserved.

import SwiftUI
import UIKit

// Shows a thumbnail of the selected image with cancel and send controls.
// Displayed above ChatInput when an image has been picked but not yet sent.
struct ImagePreview: View {

    let image: UIImage
    let onCancel: () -> Void
    let onSend: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipped()
                .cornerRadius(8)

            Spacer()

            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.title2)
            }

            Button(action: onSend) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color(.systemBackground))
    }
}
