// Copyright (c) Yalochat, Inc. All rights reserved.

import { compressWaveformForPreview } from '../use-cases/audio-processing';

describe('compressWaveformForPreview', () => {
  it('fills slot directly when totalSamples <= bins', () => {
    const bins = new Array(10).fill(0);
    const result = compressWaveformForPreview(0.5, 3, bins);
    expect(result[2]).toBe(0.5);
    expect(result.length).toBe(10);
  });

  it('does not mutate the original array', () => {
    const bins = new Array(5).fill(0.1);
    const original = [...bins];
    compressWaveformForPreview(0.9, 3, bins);
    expect(bins).toEqual(original);
  });

  it('compresses when totalSamples exceeds bins', () => {
    const bins = [0.1, 0.2, 0.3, 0.4, 0.5];
    const result = compressWaveformForPreview(0.9, 7, bins);
    expect(result.length).toBe(5);
    // The last element should be the new point
    expect(result[result.length - 1]).toBe(0.9);
  });

  it('preserves max value at target bin', () => {
    const bins = [0.1, 0.2, 0.3, 0.4, 0.5];
    // totalSamples = 6, targetBin = 6 % 5 = 1
    const result = compressWaveformForPreview(0.9, 6, bins);
    // bins[1] should be max(bins[1], bins[2]) = max(0.2, 0.3) = 0.3
    expect(result[1]).toBe(Math.max(bins[1], bins[2]));
  });
});
