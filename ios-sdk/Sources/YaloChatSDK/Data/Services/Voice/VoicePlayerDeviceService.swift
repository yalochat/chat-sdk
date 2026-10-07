// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation

/// Plays through `AVAudioPlayer`.
///
/// The audio is declared as spoken, so other audio is paused while a note
/// plays, and a note the person chose to hear plays with the silent switch on.
@MainActor
final class VoicePlayerDeviceService: NSObject, VoicePlayerService {
    private let session: AudioSession
    private let players: (URL) throws -> AVAudioPlayer
    private var player: AVAudioPlayer?
    private var onFinished: (@MainActor () -> Void)?

    init(
        session: AudioSession = AVAudioSession.sharedInstance(),
        players: @escaping (URL) throws -> AVAudioPlayer = AVAudioPlayer.init(contentsOf:)
    ) {
        self.session = session
        self.players = players
    }

    var position: TimeInterval {
        player?.currentTime ?? 0
    }

    var duration: TimeInterval {
        player?.duration ?? 0
    }

    func load(_ file: URL, onFinished: @escaping @MainActor () -> Void) throws {
        stop()
        let loaded: AVAudioPlayer
        do {
            loaded = try players(file)
        } catch {
            throw VoicePlayerServiceError.unplayable
        }
        loaded.delegate = self
        loaded.prepareToPlay()
        player = loaded
        self.onFinished = onFinished
    }

    func play() {
        guard let player else {
            return
        }
        try? session.setCategory(.playback, mode: .spokenAudio, options: [])
        try? session.setActive(true, options: [])
        player.play()
    }

    func pause() {
        guard let player else {
            return
        }
        player.pause()
        deactivate()
    }

    func stop() {
        guard let loaded = player else {
            return
        }
        player = nil
        onFinished = nil
        loaded.delegate = nil
        loaded.stop()
        deactivate()
    }

    /// Lets whatever the note interrupted, like music, carry on.
    private func deactivate() {
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    private func finished(_ finished: ObjectIdentifier) {
        // A note replaced while its end was on the way does not count.
        guard let player, ObjectIdentifier(player) == finished else {
            return
        }
        deactivate()
        onFinished?()
    }
}

extension VoicePlayerDeviceService: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let finished: ObjectIdentifier = ObjectIdentifier(player)
        Task { @MainActor in
            self.finished(finished)
        }
    }
}
