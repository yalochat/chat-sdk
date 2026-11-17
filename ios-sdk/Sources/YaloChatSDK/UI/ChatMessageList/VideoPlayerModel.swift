// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation

/// Plays a video the person chose to watch, with sound even when the silent
/// switch is on, the same as a voice note.
@MainActor
final class VideoPlayerModel: ObservableObject {
    let player: AVPlayer
    private let session: AudioSession
    private let log: YaloLog
    private var isStopped: Bool = false

    init(file: URL, session: AudioSession = AVAudioSession.sharedInstance(), logLevel: LogLevel = .warn) {
        self.player = AVPlayer(url: file)
        self.session = session
        self.log = YaloLog("VideoPlayer", level: logLevel)
    }

    func start() async {
        guard !isStopped else {
            return
        }
        do {
            try await session.activate(.playback, mode: .moviePlayback, options: [])
        } catch {
            log.warn("the speaker is not available", error: error)
        }
        // Closed while the audio was switching over.
        guard !isStopped else {
            session.deactivate()
            return
        }
        player.play()
    }

    func stop() {
        guard !isStopped else {
            return
        }
        isStopped = true
        player.pause()
        player.replaceCurrentItem(with: nil)
        session.deactivate()
    }
}
