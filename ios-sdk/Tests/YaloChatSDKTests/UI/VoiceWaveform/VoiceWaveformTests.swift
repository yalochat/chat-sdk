// Copyright (c) Yalochat, Inc. All rights reserved.

import CoreGraphics
import Testing
@testable import YaloChatSDK

@MainActor
struct VoiceWaveformTests {
    @Test func barsShareTheWidthAndGrowWithTheSound() {
        let bars: [VoiceWaveform.Bar] = VoiceWaveform.bars(
            amplitudes: [0, 1],
            size: CGSize(width: 20, height: 10),
            progress: 0.5
        )

        #expect(bars == [
            VoiceWaveform.Bar(rect: CGRect(x: 3.5, y: 4, width: 3, height: 2), isPlayed: true),
            VoiceWaveform.Bar(rect: CGRect(x: 13.5, y: 0, width: 3, height: 10), isPlayed: false),
        ])
    }

    @Test func narrowSpaceMakesNarrowerBars() {
        let bars: [VoiceWaveform.Bar] = VoiceWaveform.bars(
            amplitudes: Array(repeating: 0.5, count: 10),
            size: CGSize(width: 10, height: 10),
            progress: 1
        )

        #expect(bars.allSatisfy { bar in abs(bar.rect.width - 0.6) < 0.001 && bar.isPlayed })
    }

    @Test(arguments: [
        ([], CGSize(width: 10, height: 10)),
        ([0.5], CGSize(width: 0, height: 10)),
        ([0.5], CGSize(width: 10, height: 0)),
    ] as [([Float], CGSize)])
    func nothingToDrawHasNoBars(amplitudes: [Float], size: CGSize) {
        #expect(VoiceWaveform.bars(amplitudes: amplitudes, size: size, progress: 1).isEmpty)
    }

    @Test(arguments: [
        (0, "0:00"),
        (9.9, "0:09"),
        (65, "1:05"),
        (-1, "0:00"),
    ] as [(Double, String)])
    func durationsReadAsMinutesAndSeconds(seconds: Double, expected: String) {
        #expect(VoiceWaveform.duration(seconds) == expected)
    }

    @Test func waveformRenders() {
        #expect(renders(VoiceWaveform(amplitudes: [0.1, 0.9], progress: 0.5).frame(width: 140, height: 24)))
    }
}
