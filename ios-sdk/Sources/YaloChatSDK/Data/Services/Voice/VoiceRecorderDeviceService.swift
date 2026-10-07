// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation

/// Records through `AVAudioRecorder`.
///
/// AAC in an MP4 container, the same format the Android SDK records, which
/// every client of the product can play.
@MainActor
final class VoiceRecorderDeviceService: VoiceRecorderService {
    let mimeType: String = "audio/mp4"
    let fileExtension: String = "m4a"

    private static let settings: [String: Any] = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVSampleRateKey: 44_100,
        AVNumberOfChannelsKey: 1,
        AVEncoderBitRateKey: 64_000,
    ]

    private let session: AudioSession
    private let permission: () async -> Bool
    private let recorders: (URL, [String: Any]) throws -> AVAudioRecorder
    private var recorder: AVAudioRecorder?

    init(
        session: AudioSession = AVAudioSession.sharedInstance(),
        permission: @escaping () async -> Bool = VoiceRecorderDeviceService.askForMicrophone,
        recorders: @escaping (URL, [String: Any]) throws -> AVAudioRecorder = AVAudioRecorder.init(url:settings:)
    ) {
        self.session = session
        self.permission = permission
        self.recorders = recorders
    }

    func start(_ target: URL) async throws {
        guard recorder == nil else {
            throw VoiceRecorderServiceError.alreadyRecording
        }
        guard await permission() else {
            throw VoiceRecorderServiceError.permissionDenied
        }
        // Another start may have won while the person was being asked.
        guard recorder == nil else {
            throw VoiceRecorderServiceError.alreadyRecording
        }
        do {
            try FileManager.default.createDirectory(
                at: target.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true, options: [])
            let started: AVAudioRecorder = try recorders(target, Self.settings)
            started.isMeteringEnabled = true
            guard started.record() else {
                throw VoiceRecorderServiceError.unavailable
            }
            recorder = started
        } catch {
            deactivate()
            throw VoiceRecorderServiceError.unavailable
        }
    }

    func amplitude() -> Float {
        guard let recorder else {
            return 0
        }
        recorder.updateMeters()
        // Decibels below the loudest the microphone hears, which is zero.
        let decibels: Float = recorder.peakPower(forChannel: 0)
        return min(max(pow(10, decibels / 20), 0), 1)
    }

    func stop() throws {
        guard let running = recorder else {
            throw VoiceRecorderServiceError.notRecording
        }
        recorder = nil
        running.stop()
        deactivate()
    }

    /// Lets whatever the recording interrupted, like music, carry on.
    private func deactivate() {
        try? session.setActive(false, options: .notifyOthersOnDeactivation)
    }

    nonisolated static func askForMicrophone() async -> Bool {
        if #available(iOS 17, *) {
            return await AVAudioApplication.requestRecordPermission()
        }
        return await withCheckedContinuation { continuation in
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                continuation.resume(returning: granted)
            }
        }
    }
}
