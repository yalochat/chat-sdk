// Copyright (c) Yalochat, Inc. All rights reserved.

// Streaming max-pool compressor with doubling stride. Each new sample is folded
// into the current bin using max-pooling. When the buffer fills, adjacent bins are
// pairwise merged so the older half of the recording lives in the first half of the
// buffer and the stride for new samples doubles. Memory stays O(binCount) regardless
// of recording length, and snapshot() always spans the entire recording uniformly.
//
// Mirrors Flutter WaveformCompressor introduced in PR #146.
final class WaveformCompressor {

    let binCount: Int
    let defaultValue: Double

    private var bins: [Double]
    private var writeIdx = 0
    private var stride = 1
    private var countInBin = 0
    private var currentBinHasData = false

    init(binCount: Int, defaultValue: Double = -30.0) {
        // halve() merges pairs — an odd binCount silently drops the last bin.
        precondition(binCount == 0 || binCount % 2 == 0, "binCount must be even (got \(binCount))")
        self.binCount = binCount
        self.defaultValue = defaultValue
        self.bins = Array(repeating: defaultValue, count: binCount)
    }

    func pushSample(_ sample: Double) {
        guard binCount > 0 else { return }
        if !currentBinHasData || sample > bins[writeIdx] {
            bins[writeIdx] = sample
            currentBinHasData = true
        }
        countInBin += 1
        guard countInBin >= stride else { return }
        countInBin = 0
        writeIdx += 1
        currentBinHasData = false
        guard writeIdx >= binCount else { return }
        halve()
    }

    func snapshot() -> [Double] {
        let filled = writeIdx + (currentBinHasData ? 1 : 0)
        guard filled > 0 && filled < binCount else { return bins }
        return (0..<binCount).map { i in bins[(i * filled) / binCount] }
    }

    func reset() {
        bins = Array(repeating: defaultValue, count: binCount)
        writeIdx = 0
        stride = 1
        countInBin = 0
        currentBinHasData = false
    }

    private func halve() {
        let half = binCount / 2
        for i in 0..<half {
            bins[i] = Swift.max(bins[2 * i], bins[2 * i + 1])
        }
        for i in half..<binCount {
            bins[i] = defaultValue
        }
        writeIdx = half
        stride *= 2
        currentBinHasData = false
    }
}
