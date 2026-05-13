// Copyright (c) Yalochat, Inc. All rights reserved.

import { describe, expect, it } from 'vitest';
import { WaveformCompressor } from './waveform-compressor';

function pushAll(compressor: WaveformCompressor, samples: number[]): void {
  for (const sample of samples) {
    compressor.pushSample(sample);
  }
}

describe('WaveformCompressor', () => {
  it('starts with a zero-filled buffer of the requested size', () => {
    const compressor = new WaveformCompressor(4);

    expect(compressor.snapshot()).toEqual([0, 0, 0, 0]);
  });

  it('stretches a short recording across the full buffer so the tail does not stay flat', () => {
    const compressor = new WaveformCompressor(4);

    pushAll(compressor, [0.2, 0.8]);

    expect(compressor.snapshot()).toEqual([0.2, 0.2, 0.8, 0.8]);
  });

  it('returns a flat preview at the level of the only sample when a single sample has been pushed', () => {
    const compressor = new WaveformCompressor(4);

    compressor.pushSample(0.5);

    expect(compressor.snapshot()).toEqual([0.5, 0.5, 0.5, 0.5]);
  });

  it('compacts older samples and doubles the stride when the buffer fills', () => {
    const compressor = new WaveformCompressor(4);

    pushAll(compressor, [0.2, 0.9, 0.1, 0.4, 0.5]);

    expect(compressor.snapshot()).toEqual([0.9, 0.9, 0.4, 0.5]);
  });

  it('keeps the peak of each merged bin pair when halving', () => {
    const compressor = new WaveformCompressor(4);

    pushAll(compressor, [0.1, 0.7, 0.3, 0.8, 0.2, 0.6]);

    expect(compressor.snapshot()).toEqual([0.7, 0.7, 0.8, 0.6]);
  });

  it('preserves the overall waveform shape across the full recording', () => {
    const compressor = new WaveformCompressor(4);
    const samples = [
      ...new Array(64).fill(0.9),
      ...new Array(64).fill(0.1),
      ...new Array(64).fill(0.7),
      ...new Array(63).fill(0.2),
    ];

    pushAll(compressor, samples);

    expect(compressor.snapshot()).toEqual([0.9, 0.1, 0.7, 0.2]);
  });

  it('keeps memory bounded regardless of how many samples are pushed', () => {
    const compressor = new WaveformCompressor(4);

    for (let i = 0; i < 10_000; i++) {
      compressor.pushSample(Math.random());
    }

    expect(compressor.snapshot()).toHaveLength(4);
  });

  it('produces values within the normalized range when given normalized input', () => {
    const compressor = new WaveformCompressor(40);

    for (let i = 0; i < 200; i++) {
      compressor.pushSample((i % 10) / 10);
    }

    const result = compressor.snapshot();
    expect(result).toHaveLength(40);
    for (const value of result) {
      expect(value).toBeGreaterThanOrEqual(0);
      expect(value).toBeLessThanOrEqual(1);
    }
  });

  it('clears the buffer and rewinds the stride on reset', () => {
    const compressor = new WaveformCompressor(4);
    pushAll(compressor, [0.5, 0.9, 0.3, 0.1, 0.7]);

    compressor.reset();

    expect(compressor.snapshot()).toEqual([0, 0, 0, 0]);
  });
});
