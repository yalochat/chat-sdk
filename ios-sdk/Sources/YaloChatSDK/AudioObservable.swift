// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
import Foundation
import os

class AudioObservable: NSObject, ObservableObject {

    @Published var isRecording = false
    @Published var durationText = "0:00"
    @Published var recordingAmplitudes: [Double] = Array(repeating: -30.0, count: 48)
    @Published var playingMessageId: Int64? = nil

    private static let log = Logger(subsystem: "com.yalo.chat.demo", category: "AudioObservable")

    private var audioRecorder: AVAudioRecorder?
    private var audioPlayer: AVAudioPlayer?
    private var recordingTimer: Timer?
    private var recordingStartTime: Date?
    private var recordingFileURL: URL?
    private let waveformCompressor = WaveformCompressor(binCount: 48, defaultValue: -30.0)

    struct RecordingData {
        let fileName: String
        let amplitudes: [Double]
        let durationMs: Int64
    }

    func startRecording() {
        AVAudioSession.sharedInstance().requestRecordPermission { [weak self] granted in
            DispatchQueue.main.async {
                guard granted else { return }
                self?.beginRecording()
            }
        }
    }

    private func beginRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            Self.log.error("Audio session error: \(error)")
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")
        recordingFileURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: url, settings: settings)
            audioRecorder?.isMeteringEnabled = true
            audioRecorder?.record()
        } catch {
            Self.log.error("AVAudioRecorder failed: \(error)")
            recordingFileURL = nil
            try? session.setActive(false)
            return
        }

        waveformCompressor.reset()
        recordingStartTime = Date()
        isRecording = true
        durationText = "0:00"
        recordingAmplitudes = Array(repeating: -30.0, count: 48)

        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.025, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func tick() {
        guard let recorder = audioRecorder, recorder.isRecording else { return }
        recorder.updateMeters()
        let dBFS = Double(recorder.averagePower(forChannel: 0))
        waveformCompressor.pushSample(dBFS)
        recordingAmplitudes = waveformCompressor.snapshot()

        if let start = recordingStartTime {
            let elapsed = Int(Date().timeIntervalSince(start))
            durationText = String(format: "%d:%02d", elapsed / 60, elapsed % 60)
        }
    }

    func cancelRecording() {
        let url = recordingFileURL
        stopRecordingSession()
        if let url { try? FileManager.default.removeItem(at: url) }
    }

    func stopRecording() -> RecordingData? {
        guard let url = recordingFileURL, let start = recordingStartTime else {
            stopRecordingSession()
            return nil
        }

        let durationMs = Int64(Date().timeIntervalSince(start) * 1000)
        let finalAmplitudes = waveformCompressor.snapshot()

        stopRecordingSession()

        guard durationMs > 500 else {
            try? FileManager.default.removeItem(at: url)
            return nil
        }

        return RecordingData(
            fileName: url.path,
            amplitudes: finalAmplitudes,
            durationMs: durationMs
        )
    }

    private func stopRecordingSession() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        audioRecorder?.stop()
        audioRecorder = nil
        recordingFileURL = nil
        recordingStartTime = nil
        isRecording = false
        durationText = "0:00"
        recordingAmplitudes = Array(repeating: -30.0, count: 48)
        // Release the microphone so other apps (phone, Siri) can record.
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    func togglePlayback(messageId: Int64, fileName: String) {
        if playingMessageId == messageId {
            audioPlayer?.stop()
            audioPlayer = nil
            playingMessageId = nil
            deactivatePlaybackSession()
            return
        }
        audioPlayer?.stop()
        audioPlayer = nil

        guard !fileName.isEmpty,
              let player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileName)) else {
            return
        }

        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            Self.log.error("Playback session error: \(error)")
            return
        }

        player.delegate = self
        player.play()
        audioPlayer = player
        playingMessageId = messageId
    }

    private func deactivatePlaybackSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }

    deinit {
        recordingTimer?.invalidate()
        audioRecorder?.stop()
        audioPlayer?.stop()
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}

extension AudioObservable: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.playingMessageId = nil
            self?.audioPlayer = nil
            self?.deactivatePlaybackSession()
        }
    }
}

