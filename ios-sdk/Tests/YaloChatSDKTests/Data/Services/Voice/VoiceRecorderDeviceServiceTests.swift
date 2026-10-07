// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
import Foundation
import Testing
@testable import YaloChatSDK

/// Stands in for the microphone, which tests cannot open.
private final class StubRecorder: AVAudioRecorder, @unchecked Sendable {
    var records: Bool = true
    var decibels: Float = -160
    private(set) var isStopped: Bool = false

    override func record() -> Bool {
        records
    }

    override func updateMeters() {}

    override func peakPower(forChannel channelNumber: Int) -> Float {
        decibels
    }

    override func stop() {
        isStopped = true
    }
}

@MainActor
struct VoiceRecorderDeviceServiceTests {
    private let folder: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-voice-tests-\(UUID().uuidString)", isDirectory: true)

    private var target: URL {
        folder.appendingPathComponent("notes/voice-\(UUID().uuidString).m4a")
    }

    private static func service(
        session: StubAudioSession = StubAudioSession(),
        granted: Bool = true,
        recorders: @escaping (URL, [String: Any]) throws -> AVAudioRecorder = { url, settings in
            try StubRecorder(url: url, settings: settings)
        }
    ) -> VoiceRecorderDeviceService {
        VoiceRecorderDeviceService(session: session, permission: { granted }, recorders: recorders)
    }

    @Test func recordsSomethingEveryClientOfTheProductCanPlay() {
        let service: VoiceRecorderDeviceService = Self.service()

        #expect(service.mimeType == "audio/mp4")
        #expect(service.fileExtension == "m4a")
    }

    @Test func recordsAacIntoTheTargetItWasPointedAt() async throws {
        var recorded: (url: URL, settings: [String: Any])?
        let service: VoiceRecorderDeviceService = Self.service { url, settings in
            recorded = (url, settings)
            return try StubRecorder(url: url, settings: settings)
        }
        let target: URL = target

        try await service.start(target)

        let sent: (url: URL, settings: [String: Any]) = try #require(recorded)
        #expect(sent.url == target)
        #expect(sent.settings[AVFormatIDKey] as? AudioFormatID == kAudioFormatMPEG4AAC)
        #expect(FileManager.default.fileExists(atPath: target.deletingLastPathComponent().path))
        try service.stop()
    }

    @Test func refusesToRecordWithoutThePermission() async {
        let service: VoiceRecorderDeviceService = Self.service(granted: false)

        await #expect(throws: VoiceRecorderServiceError.permissionDenied) {
            try await service.start(target)
        }
    }

    @Test func refusesASecondRecordingWhileOneIsRunning() async throws {
        let service: VoiceRecorderDeviceService = Self.service()
        try await service.start(target)

        await #expect(throws: VoiceRecorderServiceError.alreadyRecording) {
            try await service.start(target)
        }
        try service.stop()
    }

    @Test func onlyOneOfTwoStartsWaitingOnThePermissionRecords() async throws {
        let service: VoiceRecorderDeviceService = VoiceRecorderDeviceService(
            session: StubAudioSession(),
            permission: {
                await Task.yield()
                return true
            },
            recorders: { url, settings in
                try StubRecorder(url: url, settings: settings)
            }
        )
        let first: URL = target
        let second: URL = target

        async let firstStart: Bool = (try? await service.start(first)) != nil
        async let secondStart: Bool = (try? await service.start(second)) != nil

        #expect(await [firstStart, secondStart].filter { $0 }.count == 1)
        try service.stop()
    }

    @Test func reportsAMicrophoneTheDeviceWillNotOpen() async throws {
        let service: VoiceRecorderDeviceService = Self.service { url, settings in
            let refusing: StubRecorder = try StubRecorder(url: url, settings: settings)
            refusing.records = false
            return refusing
        }

        await #expect(throws: VoiceRecorderServiceError.unavailable) {
            try await service.start(target)
        }
        // Nothing was kept, so there is nothing to stop.
        #expect(throws: VoiceRecorderServiceError.notRecording) {
            try service.stop()
        }
    }

    @Test func reportsARecorderTheDeviceCannotBuild() async {
        let service: VoiceRecorderDeviceService = Self.service { _, _ in
            throw CocoaError(.fileWriteUnknown)
        }

        await #expect(throws: VoiceRecorderServiceError.unavailable) {
            try await service.start(target)
        }
    }

    @Test func takesTheAudioOverWhileRecordingAndHandsItBack() async throws {
        let session: StubAudioSession = StubAudioSession()
        let service: VoiceRecorderDeviceService = Self.service(session: session)

        try await service.start(target)
        #expect(session.category == .playAndRecord)
        #expect(session.isActive)

        try service.stop()
        #expect(!session.isActive)
        #expect(session.deactivationOptions == .notifyOthersOnDeactivation)
    }

    @Test func reportsAnAudioSessionTheDeviceWillNotHandOver() async {
        let session: StubAudioSession = StubAudioSession()
        session.failure = CocoaError(.featureUnsupported)

        await #expect(throws: VoiceRecorderServiceError.unavailable) {
            try await Self.service(session: session).start(target)
        }
    }

    @Test func reportsAFolderThatCannotBeCreated() async throws {
        let blocker: URL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("not a folder".utf8).write(to: blocker)
        let service: VoiceRecorderDeviceService = Self.service()

        await #expect(throws: VoiceRecorderServiceError.unavailable) {
            try await service.start(blocker.appendingPathComponent("voice.m4a"))
        }
    }

    @Test func saysHowLoudTheRoomIsBetweenNothingAndEverything() async throws {
        var stub: StubRecorder?
        let service: VoiceRecorderDeviceService = Self.service { url, settings in
            let recorder: StubRecorder = try StubRecorder(url: url, settings: settings)
            stub = recorder
            return recorder
        }
        try await service.start(target)
        let recorder: StubRecorder = try #require(stub)

        recorder.decibels = 0
        #expect(service.amplitude() == 1)
        recorder.decibels = -20
        #expect(abs(service.amplitude() - 0.1) < 0.0001)
        recorder.decibels = -160
        #expect(service.amplitude() < 0.0001)
        try service.stop()
    }

    @Test func hearsNothingWhileNothingIsBeingRecorded() {
        #expect(Self.service().amplitude() == 0)
    }

    @Test func letsGoOfTheMicrophoneOnceTheRecordingIsFinished() async throws {
        var stub: StubRecorder?
        let service: VoiceRecorderDeviceService = Self.service { url, settings in
            let recorder: StubRecorder = try StubRecorder(url: url, settings: settings)
            stub = recorder
            return recorder
        }
        try await service.start(target)

        try service.stop()

        #expect(try #require(stub).isStopped)
        #expect(service.amplitude() == 0)
    }

    @Test func refusesToStopWhenNothingIsRecording() {
        #expect(throws: VoiceRecorderServiceError.notRecording) {
            try Self.service().stop()
        }
    }

    @Test func recordsAgainAfterARecordingWasFinished() async throws {
        let service: VoiceRecorderDeviceService = Self.service()
        try await service.start(target)
        try service.stop()

        try await service.start(target)

        try service.stop()
    }
}
