// Copyright (c) Yalochat, Inc. All rights reserved.

import AVFoundation
import Testing
@testable import YaloChatSDK

@MainActor
struct VideoPlayerModelTests {
    private struct SpeakerUnavailable: Error {}

    @Test func playsWithSoundEvenInSilentMode() async throws {
        let session: StubAudioSession = StubAudioSession()
        let model: VideoPlayerModel = VideoPlayerModel(file: try await videoFile(), session: session)

        await model.start()

        #expect(session.category == .playback)
        #expect(session.mode == .moviePlayback)
        #expect(session.isActive)
    }

    @Test func letsOtherAudioCarryOnOnceClosed() async throws {
        let session: StubAudioSession = StubAudioSession()
        let model: VideoPlayerModel = VideoPlayerModel(file: try await videoFile(), session: session)
        await model.start()

        model.stop()

        #expect(await eventually { !session.isActive })
        #expect(session.deactivationOptions == .notifyOthersOnDeactivation)
        #expect(model.player.currentItem == nil)
    }

    @Test func leavesTheAudioAloneWhenClosedBeforeItStarts() async throws {
        let session: StubAudioSession = StubAudioSession()
        let model: VideoPlayerModel = VideoPlayerModel(file: try await videoFile(), session: session)

        model.stop()
        await model.start()

        #expect(session.category == nil)
    }

    @Test func leavesTheAudioAloneWhenClosedWhileItSwitches() async throws {
        let gate: DispatchSemaphore = DispatchSemaphore(value: 0)
        let session: StubAudioSession = StubAudioSession(gate: gate)
        let model: VideoPlayerModel = VideoPlayerModel(file: try await videoFile(), session: session)
        let starting: Task<Void, Never> = Task { await model.start() }
        #expect(await eventually { session.isActivating })

        model.stop()
        gate.signal()
        await starting.value

        #expect(await eventually { !session.isActive })
    }

    @Test func stillPlaysWhenTheSpeakerIsNotAvailable() async throws {
        let session: StubAudioSession = StubAudioSession()
        session.failure = SpeakerUnavailable()
        let model: VideoPlayerModel = VideoPlayerModel(file: try await videoFile(), session: session)

        await model.start()

        #expect(model.player.rate > 0)
    }
}
