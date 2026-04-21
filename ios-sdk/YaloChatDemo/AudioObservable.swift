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
    private var rawAmplitudes: [Double] = []
    private var recordingStartTime: Date?
    private var recordingFileURL: URL?

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
            return
        }

        rawAmplitudes = []
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
        rawAmplitudes.append(dBFS)
        recordingAmplitudes = compressWaveform(rawAmplitudes, to: 48)

        if let start = recordingStartTime {
            let elapsed = Int(Date().timeIntervalSince(start))
            durationText = String(format: "%d:%02d", elapsed / 60, elapsed % 60)
        }
    }

    func cancelRecording() {
        if let url = recordingFileURL {
            stopRecordingSession()
            try? FileManager.default.removeItem(at: url)
        } else {
            stopRecordingSession()
        }
    }

    func stopRecording() -> RecordingData? {
        guard let url = recordingFileURL, let start = recordingStartTime else {
            stopRecordingSession()
            return nil
        }

        let durationMs = Int64(Date().timeIntervalSince(start) * 1000)
        let ampsCopy = rawAmplitudes

        stopRecordingSession()

        guard durationMs > 500 else {
            try? FileManager.default.removeItem(at: url)
            return nil
        }

        return RecordingData(
            fileName: url.path,
            amplitudes: compressWaveform(ampsCopy, to: 48),
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
        rawAmplitudes = []
        isRecording = false
        durationText = "0:00"
        recordingAmplitudes = Array(repeating: -30.0, count: 48)
    }

    func togglePlayback(messageId: Int64, fileName: String) {
        if playingMessageId == messageId {
            audioPlayer?.stop()
            audioPlayer = nil
            playingMessageId = nil
            return
        }
        audioPlayer?.stop()
        audioPlayer = nil

        guard !fileName.isEmpty,
              let player = try? AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileName)) else {
            return
        }
        player.delegate = self
        player.play()
        audioPlayer = player
        playingMessageId = messageId
    }

    // Mirrors Flutter AudioProcessingUseCase.compressWaveformForPreview:
    // maps rawSamples to exactly `count` bins — max of each bin when compressing,
    // nearest-neighbor repeat when stretching.
    private func compressWaveform(_ samples: [Double], to count: Int) -> [Double] {
        guard !samples.isEmpty else { return Array(repeating: -60.0, count: count) }
        if samples.count <= count {
            return (0..<count).map { i in
                let src = Int(Double(i) * Double(samples.count) / Double(count))
                return samples[min(src, samples.count - 1)]
            }
        }
        let binSize = Double(samples.count) / Double(count)
        return (0..<count).map { i in
            let start = Int(Double(i) * binSize)
            let end = min(Int(Double(i + 1) * binSize), samples.count)
            return samples[start..<end].max() ?? -60.0
        }
    }
}

extension AudioObservable: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async { [weak self] in
            self?.playingMessageId = nil
            self?.audioPlayer = nil
        }
    }
}
