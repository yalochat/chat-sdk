// Copyright (c) Yalochat, Inc. All rights reserved.

import AVKit
import SwiftUI

/// Plays `file` full screen with the system controls, from the start, and
/// lets it go once closed.
struct VideoPlayerScreen: View {
    @Environment(\.dismiss) private var dismiss: DismissAction
    @StateObject private var model: VideoPlayerModel

    init(file: URL) {
        _model = StateObject(wrappedValue: VideoPlayerModel(file: file))
    }

    var body: some View {
        // The close button gets its own bar, since the system controls use the corners of the video.
        VStack(alignment: .leading, spacing: 0) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel(Text("Close", bundle: .module))
            .accessibilityIdentifier("yalo-chat-video-close")
            .padding(.horizontal, 8)
            VideoPlayer(player: model.player)
                .ignoresSafeArea(edges: .bottom)
        }
        .background(Color.black.ignoresSafeArea())
        .accessibilityIdentifier("yalo-chat-video-player")
        .task {
            await model.start()
        }
        .onDisappear {
            model.stop()
        }
    }
}
