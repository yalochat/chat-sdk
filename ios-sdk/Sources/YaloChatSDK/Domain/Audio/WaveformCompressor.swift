// Copyright (c) Yalochat, Inc. All rights reserved.

import Foundation

/// Turns however many amplitude samples a recording produces into a fixed
/// number of bars, without keeping the samples.
///
/// Each bar keeps the loudest sample folded into it. When the last bar is
/// written the bars are merged in pairs and every bar from then on covers twice
/// as much time, so memory stays the same however long the recording runs.
/// Same algorithm as the web and Android SDKs, so a note looks the same on
/// every client.
struct WaveformCompressor {
    let barCount: Int
    private var bars: [Float]
    private var writeIndex: Int = 0
    private var stride: Int = 1
    private var samplesInBar: Int = 0

    init(barCount: Int) {
        self.barCount = max(barCount, 0)
        self.bars = Array(repeating: 0, count: self.barCount)
    }

    /// Folds `sample`, between zero and one, into the waveform.
    mutating func push(_ sample: Float) {
        guard barCount > 0 else {
            return
        }
        bars[writeIndex] = max(bars[writeIndex], sample)
        samplesInBar += 1
        guard samplesInBar >= stride else {
            return
        }
        samplesInBar = 0
        writeIndex += 1
        guard writeIndex >= barCount else {
            return
        }
        halve()
    }

    /// Always `barCount` bars long. A recording that has not filled the bars
    /// yet is stretched across all of them.
    func snapshot() -> [Float] {
        let filled: Int = writeIndex + (samplesInBar > 0 ? 1 : 0)
        guard filled > 0, filled < barCount else {
            return bars
        }
        return (0..<barCount).map { index in
            bars[index * filled / barCount]
        }
    }

    private mutating func halve() {
        let half: Int = barCount / 2
        for index in 0..<half {
            bars[index] = max(bars[2 * index], bars[2 * index + 1])
        }
        for index in half..<barCount {
            bars[index] = 0
        }
        writeIndex = half
        stride *= 2
    }
}
