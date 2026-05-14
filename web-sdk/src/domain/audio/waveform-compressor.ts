// Copyright (c) Yalochat, Inc. All rights reserved.

// Streaming max-pool compressor with doubling stride. Each new sample
// is folded into the current bin using max-pooling. When the buffer
// fills, adjacent bins are pairwise merged so the older half of the
// recording lives in the first half of the buffer and the stride for
// new samples doubles. Memory stays O(binCount) regardless of recording
// length, and the final waveform spans the entire recording uniformly.
export class WaveformCompressor {
  private readonly _binCount: number;
  private _bins: number[];
  private _writeIdx = 0;
  private _stride = 1;
  private _countInBin = 0;

  constructor(binCount: number) {
    this._binCount = binCount;
    this._bins = new Array(binCount).fill(0);
  }

  pushSample(sample: number): void {
    if (this._binCount <= 0) {
      return;
    }
    if (sample > this._bins[this._writeIdx]) {
      this._bins[this._writeIdx] = sample;
    }
    this._countInBin++;
    if (this._countInBin < this._stride) {
      return;
    }
    this._countInBin = 0;
    this._writeIdx++;
    if (this._writeIdx < this._binCount) {
      return;
    }
    this._halve();
  }

  snapshot(): number[] {
    const filled = this._writeIdx + (this._countInBin > 0 ? 1 : 0);
    if (filled <= 0 || filled >= this._binCount) {
      return [...this._bins];
    }
    const result = new Array<number>(this._binCount);
    for (let i = 0; i < this._binCount; i++) {
      result[i] = this._bins[Math.floor((i * filled) / this._binCount)];
    }
    return result;
  }

  reset(): void {
    this._bins = new Array(this._binCount).fill(0);
    this._writeIdx = 0;
    this._stride = 1;
    this._countInBin = 0;
  }

  private _halve(): void {
    const half = Math.floor(this._binCount / 2);
    for (let i = 0; i < half; i++) {
      this._bins[i] = Math.max(this._bins[2 * i], this._bins[2 * i + 1]);
    }
    for (let i = half; i < this._binCount; i++) {
      this._bins[i] = 0;
    }
    this._writeIdx = half;
    this._stride *= 2;
  }
}
