// Copyright (c) Yalochat, Inc. All rights reserved.

import Combine
import Foundation
import Testing
@testable import YaloChatSDK

/// Keeps the last value a publisher sent.
@MainActor
final class Latest<Value> {
    private(set) var value: Value?
    private var subscription: AnyCancellable?

    init(_ publisher: AnyPublisher<Value, Never>) {
        subscription = publisher.sink { [weak self] value in
            self?.value = value
        }
    }
}

@MainActor
final class ManualClock {
    var now: Date = Date(timeIntervalSince1970: 1_700_000_000)
}

@MainActor
struct VoiceRepositoryLocalTests {
    private let recorder: FakeVoiceRecorder = FakeVoiceRecorder()
    private let player: FakeVoicePlayer = FakeVoicePlayer()
    private let clock: ManualClock = ManualClock()
    private let directory: URL = FileManager.default.temporaryDirectory
        .appendingPathComponent("yalo-chat-voice-repository-tests-\(UUID().uuidString)", isDirectory: true)

    private func repository() -> VoiceRepositoryLocal {
        let clock: ManualClock = clock
        return VoiceRepositoryLocal(
            recorder: recorder,
            player: player,
            directory: directory,
            now: { clock.now },
            sleep: { _ in
                try await Task.sleep(nanoseconds: 1_000_000)
            }
        )
    }

    private func audioFile() throws -> URL {
        let file: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).m4a")
        try Data("audio".utf8).write(to: file)
        return file
    }

    @Test func recordingStartsWithASilentWindowInTheDirectory() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let recording: Latest<VoiceRecording?> = Latest(repository.recording)

        try await repository.startRecording()

        let target: URL = try #require(recorder.target)
        #expect(recording.value == VoiceRecording(elapsed: 0, amplitudes: Array(repeating: 0, count: 40)))
        #expect(target.deletingLastPathComponent().standardizedFileURL == directory.standardizedFileURL)
        #expect(target.pathExtension == "m4a")
        repository.release()
    }

    @Test func theWindowMovesWithWhatTheMicrophoneHears() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let recording: Latest<VoiceRecording?> = Latest(repository.recording)
        try await repository.startRecording()

        recorder.level = 0.8
        clock.now = clock.now.addingTimeInterval(2)

        #expect(await eventually {
            recording.value??.amplitudes.last == 0.8 && recording.value??.elapsed == 2
        })
        #expect(recording.value??.amplitudes.count == 40)
        repository.release()
    }

    @Test func stoppingHandsBackTheNote() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let recording: Latest<VoiceRecording?> = Latest(repository.recording)
        try await repository.startRecording()
        let target: URL = try #require(recorder.target)
        clock.now = clock.now.addingTimeInterval(4)

        let note: VoiceNote = try repository.stopRecording()

        #expect(note.duration == 4)
        #expect(note.amplitudes.count == 40)
        #expect(note.mimeType == "audio/mp4")
        #expect(note.fileName == target.lastPathComponent)
        #expect(note.localFileName == target.lastPathComponent)
        #expect(note.byteCount == Int64(recorder.bytes.count))
        #expect(repository.file(of: note) != nil)
        #expect(recording.value == .some(nil))
    }

    @Test func aRecordingWithNothingInItIsThrownAway() async throws {
        let repository: VoiceRepositoryLocal = repository()
        recorder.bytes = Data()
        try await repository.startRecording()
        let target: URL = try #require(recorder.target)

        #expect(throws: VoiceRepositoryError.nothingRecorded) {
            try repository.stopRecording()
        }
        #expect(!FileManager.default.fileExists(atPath: target.path))
    }

    @Test func aRecordingTheMicrophoneCannotFinishIsThrownAway() async throws {
        let repository: VoiceRepositoryLocal = repository()
        recorder.stopError = VoiceRecorderServiceError.unavailable
        try await repository.startRecording()
        let target: URL = try #require(recorder.target)

        #expect(throws: VoiceRecorderServiceError.unavailable) {
            try repository.stopRecording()
        }
        #expect(!FileManager.default.fileExists(atPath: target.path))
    }

    @Test func stoppingWhileIdleIsRefused() {
        #expect(throws: VoiceRecorderServiceError.notRecording) {
            try repository().stopRecording()
        }
    }

    @Test func aSecondRecordingIsRefused() async throws {
        let repository: VoiceRepositoryLocal = repository()
        try await repository.startRecording()

        await #expect(throws: VoiceRecorderServiceError.alreadyRecording) {
            try await repository.startRecording()
        }
        repository.release()
    }

    @Test func aRefusedMicrophoneLeavesItIdle() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let recording: Latest<VoiceRecording?> = Latest(repository.recording)
        recorder.startError = VoiceRecorderServiceError.permissionDenied

        await #expect(throws: VoiceRecorderServiceError.permissionDenied) {
            try await repository.startRecording()
        }
        recorder.startError = nil
        try await repository.startRecording()

        #expect(recording.value != .some(nil))
        repository.release()
    }

    @Test func cancellingDeletesTheRecording() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let recording: Latest<VoiceRecording?> = Latest(repository.recording)
        try await repository.startRecording()
        let target: URL = try #require(recorder.target)
        try Data("partial".utf8).write(to: target)

        repository.cancelRecording()

        #expect(recording.value == .some(nil))
        #expect(recorder.target == nil)
        #expect(!FileManager.default.fileExists(atPath: target.path))
    }

    @Test func cancellingWhileAskingForTheMicrophoneRecordsNothing() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let recording: Latest<VoiceRecording?> = Latest(repository.recording)
        recorder.whileAsking = {
            repository.cancelRecording()
        }

        try await repository.startRecording()

        #expect(recording.value == .some(nil))
        #expect(recorder.target == nil)
    }

    @Test func aNoteWithNoRecordingOnTheDeviceHasNoFile() {
        let repository: VoiceRepositoryLocal = repository()

        #expect(repository.file(of: VoiceNote(duration: 1)) == nil)
        #expect(repository.file(of: VoiceNote(duration: 1, localFileName: "gone.m4a")) == nil)
    }

    @Test func playingLoadsTheNoteAndFollowsThePlayhead() throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        let file: URL = try audioFile()

        try repository.play(1, file: file)

        #expect(player.loaded == file)
        #expect(player.isPlaying)
        #expect(playback.value == VoicePlayback(messageId: 1, position: 0, duration: 3, isPlaying: true))
    }

    @Test func thePlayheadIsFollowedWhilePlaying() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        try repository.play(1, file: try audioFile())

        player.position = 1.5

        #expect(await eventually { playback.value??.position == 1.5 })
        repository.release()
    }

    @Test func pausingAndPlayingAgainCarriesOnWithoutReloading() throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        try repository.play(1, file: try audioFile())
        player.position = 1

        repository.pausePlayback()
        #expect(playback.value == VoicePlayback(messageId: 1, position: 1, duration: 3, isPlaying: false))
        try repository.play(1, file: try audioFile())

        #expect(player.loads.count == 1)
        #expect(player.isPlaying)
        #expect(playback.value??.isPlaying == true)
    }

    @Test func playingAnotherNoteReplacesTheFirst() throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        try repository.play(1, file: try audioFile())

        try repository.play(2, file: try audioFile())

        #expect(player.loads.count == 2)
        #expect(playback.value??.messageId == 2)
    }

    @Test func aNoteTheDeviceCannotPlayLeavesNothingLoaded() throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        player.loadError = VoicePlayerServiceError.unplayable

        #expect(throws: VoicePlayerServiceError.unplayable) {
            try repository.play(1, file: try audioFile())
        }
        #expect(playback.value == .some(nil))
    }

    @Test func aNoteHeardToTheEndIsRewound() throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        try repository.play(1, file: try audioFile())

        player.finish()

        #expect(playback.value == VoicePlayback(messageId: 1, position: 0, duration: 3, isPlaying: false))
    }

    @Test func recordingStopsWhateverWasPlaying() async throws {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)
        try repository.play(1, file: try audioFile())

        try await repository.startRecording()

        #expect(player.loaded == nil)
        #expect(playback.value == .some(nil))
        repository.release()
    }

    @Test func releaseLetsGoOfBoth() async throws {
        let repository: VoiceRepositoryLocal = repository()
        try repository.play(1, file: try audioFile())
        try await repository.startRecording()

        repository.release()

        #expect(recorder.target == nil)
        #expect(player.loaded == nil)
    }

    @Test func pausingWithNothingLoadedDoesNothing() {
        let repository: VoiceRepositoryLocal = repository()
        let playback: Latest<VoicePlayback?> = Latest(repository.playback)

        repository.pausePlayback()

        #expect(playback.value == .some(nil))
    }
}
