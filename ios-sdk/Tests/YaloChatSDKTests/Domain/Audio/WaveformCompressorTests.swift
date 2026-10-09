// Copyright (c) Yalochat, Inc. All rights reserved.

import Testing
@testable import YaloChatSDK

struct WaveformCompressorTests {
    @Test func startsSilent() {
        #expect(WaveformCompressor(barCount: 4).snapshot() == [0, 0, 0, 0])
    }

    @Test func stretchesAShortRecordingAcrossEveryBar() {
        var waveform: WaveformCompressor = WaveformCompressor(barCount: 4)

        waveform.push(1)
        waveform.push(0.5)

        #expect(waveform.snapshot() == [1, 1, 0.5, 0.5])
    }

    @Test func keepsTheLoudestSampleWhenTheRecordingOutgrowsTheBars() {
        var waveform: WaveformCompressor = WaveformCompressor(barCount: 4)

        for sample in [0.1, 0.9, 0.3, 0.2, 0.5] as [Float] {
            waveform.push(sample)
        }

        #expect(waveform.snapshot() == [0.9, 0.9, 0.3, 0.5])
    }

    @Test func aWaveformWithNoBarsStaysEmpty() {
        var waveform: WaveformCompressor = WaveformCompressor(barCount: 0)

        waveform.push(1)

        #expect(waveform.snapshot().isEmpty)
    }
}
