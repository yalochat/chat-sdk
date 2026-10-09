// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
import Foundation
import Testing
@testable import YaloChatSDK

/// Stands in for the speaker, so a test can say when a note ends.
private final class StubPlayer: AVAudioPlayer, @unchecked Sendable {
    private(set) var isStarted: Bool = false
    private(set) var isStopped: Bool = false

    override func prepareToPlay() -> Bool {
        true
    }

    override func play() -> Bool {
        isStarted = true
        return true
    }

    override func pause() {
        isStarted = false
    }

    override func stop() {
        isStarted = false
        isStopped = true
    }

    /// Plays the note to its end, the way the device would report it.
    @MainActor func finish() {
        isStarted = false
        delegate?.audioPlayerDidFinishPlaying?(self, successfully: true)
    }
}

@MainActor
struct VoicePlayerDeviceServiceTests {
    private static func note(seconds: Double) throws -> URL {
        let url: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).wav")
        let format: AVAudioFormat = try #require(AVAudioFormat(standardFormatWithSampleRate: 8_000, channels: 1))
        let frames: AVAudioFrameCount = AVAudioFrameCount(seconds * 8_000)
        let buffer: AVAudioPCMBuffer = try #require(AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frames))
        buffer.frameLength = frames
        let file: AVAudioFile = try AVAudioFile(forWriting: url, settings: format.settings)
        try file.write(from: buffer)
        return url
    }

    /// A service whose players are stubs, handed back through `built`.
    private static func service(
        session: StubAudioSession = StubAudioSession(),
        _ built: @escaping (StubPlayer) -> Void = { _ in }
    ) -> VoicePlayerDeviceService {
        VoicePlayerDeviceService(session: session) { url in
            let player: StubPlayer = try StubPlayer(contentsOf: url)
            built(player)
            return player
        }
    }

    @Test func saysHowLongANoteRunsOnceItIsLoaded() throws {
        let service: VoicePlayerDeviceService = Self.service()

        try service.load(try Self.note(seconds: 2)) {}

        #expect(abs(service.duration - 2) < 0.01)
        #expect(service.position == 0)
        service.stop()
    }

    @Test func reportsANoteTheDeviceWillNotPlay() throws {
        let garbage: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).m4a")
        try Data("not audio".utf8).write(to: garbage)

        #expect(throws: VoicePlayerServiceError.unplayable) {
            try VoicePlayerDeviceService(session: StubAudioSession()).load(garbage) {}
        }
    }

    @Test func reportsANoteThatIsGone() {
        let missing: URL = FileManager.default.temporaryDirectory.appendingPathComponent("\(UUID().uuidString).m4a")

        #expect(throws: VoicePlayerServiceError.unplayable) {
            try VoicePlayerDeviceService(session: StubAudioSession()).load(missing) {}
        }
    }

    @Test func saysNothingAboutAudioItWasNeverGiven() async {
        let session: StubAudioSession = StubAudioSession()
        let service: VoicePlayerDeviceService = Self.service(session: session)

        await service.play()
        service.pause()
        service.stop()

        #expect(service.position == 0)
        #expect(service.duration == 0)
        #expect(session.category == nil)
    }

    @Test func playsTheLoadedNoteAsSpokenAudio() async throws {
        let session: StubAudioSession = StubAudioSession()
        var stub: StubPlayer?
        let service: VoicePlayerDeviceService = Self.service(session: session) { stub = $0 }
        try service.load(try Self.note(seconds: 1)) {}

        await service.play()

        #expect(try #require(stub).isStarted)
        #expect(session.category == .playback)
        #expect(session.mode == .spokenAudio)
        #expect(session.isActive)
        service.stop()
    }

    @Test func pausingHandsTheAudioBack() async throws {
        let session: StubAudioSession = StubAudioSession()
        var stub: StubPlayer?
        let service: VoicePlayerDeviceService = Self.service(session: session) { stub = $0 }
        try service.load(try Self.note(seconds: 1)) {}
        await service.play()

        service.pause()

        #expect(try #require(stub).isStarted == false)
        #expect(await eventually { !session.isActive })
        #expect(session.deactivationOptions == .notifyOthersOnDeactivation)
        service.stop()
    }

    @Test func aPauseWhileTheAudioSwitchesOverWins() async throws {
        let gate: DispatchSemaphore = DispatchSemaphore(value: 0)
        let session: StubAudioSession = StubAudioSession(gate: gate)
        var stub: StubPlayer?
        let service: VoicePlayerDeviceService = Self.service(session: session) { stub = $0 }
        try service.load(try Self.note(seconds: 1)) {}
        let playing: Task<Void, Never> = Task {
            await service.play()
        }
        #expect(await eventually { session.isActivating })

        service.pause()
        gate.signal()
        await playing.value

        #expect(try #require(stub).isStarted == false)
        #expect(await eventually { !session.isActive })
        service.stop()
    }

    @Test func letsGoOfWhateverWasLoadedWhenItIsStopped() throws {
        var stub: StubPlayer?
        let service: VoicePlayerDeviceService = Self.service { stub = $0 }
        try service.load(try Self.note(seconds: 1)) {}

        service.stop()

        #expect(try #require(stub).isStopped)
        #expect(service.duration == 0)
    }

    @Test func letsGoOfTheOldNoteWhenAnotherOneIsLoaded() throws {
        var stubs: [StubPlayer] = []
        let service: VoicePlayerDeviceService = Self.service { stubs.append($0) }
        try service.load(try Self.note(seconds: 1)) {}

        try service.load(try Self.note(seconds: 3)) {}

        #expect(try #require(stubs.first).isStopped)
        #expect(abs(service.duration - 3) < 0.01)
        service.stop()
    }

    @Test func saysWhenTheNoteReachesItsEnd() async throws {
        let session: StubAudioSession = StubAudioSession()
        var stub: StubPlayer?
        let service: VoicePlayerDeviceService = Self.service(session: session) { stub = $0 }

        let finished: AsyncStream<Void>.Continuation
        let ends: AsyncStream<Void>
        (ends, finished) = AsyncStream.makeStream()
        try service.load(try Self.note(seconds: 1)) {
            finished.yield()
        }
        await service.play()
        stub?.finish()

        var iterator: AsyncStream<Void>.Iterator = ends.makeAsyncIterator()
        #expect(await iterator.next() != nil)
        #expect(await eventually { !session.isActive })
        service.stop()
    }

    @Test func aReplacedNoteDoesNotSayItFinished() async throws {
        var stubs: [StubPlayer] = []
        let service: VoicePlayerDeviceService = Self.service { stubs.append($0) }
        var replacedFinished: Bool = false
        try service.load(try Self.note(seconds: 1)) {
            replacedFinished = true
        }
        let replaced: StubPlayer = try #require(stubs.first)
        // The end of the first note is already on its way when it is replaced.
        replaced.finish()

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            do {
                try service.load(try Self.note(seconds: 1)) {
                    continuation.resume()
                }
                stubs.last?.finish()
            } catch {
                Issue.record(error)
                continuation.resume()
            }
        }

        #expect(!replacedFinished)
        service.stop()
    }
}
