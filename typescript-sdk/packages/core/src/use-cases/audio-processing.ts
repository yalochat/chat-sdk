// Copyright (c) Yalochat, Inc. All rights reserved.

/**
 * Receives a new amplitude point and recompresses the waveform preview array
 * to preserve the most data within a fixed number of bins.
 *
 * @param newPoint       Latest amplitude sample
 * @param totalSamples   Total number of samples recorded so far (1-indexed)
 * @param amplitudePreview  Current preview array (fixed length = desired bins)
 * @returns Updated preview array (same length as input)
 */
export function compressWaveformForPreview(
  newPoint: number,
  totalSamples: number,
  amplitudePreview: readonly number[],
): number[] {
  const result = [...amplitudePreview];
  const totalBins = amplitudePreview.length;

  if (totalSamples <= totalBins) {
    result[totalSamples - 1] = newPoint;
  } else {
    const targetBin = totalSamples % totalBins;
    for (let i = targetBin; i < result.length - 1; i++) {
      if (i === targetBin) {
        result[i] = Math.max(result[i], result[i + 1]);
      } else {
        result[i] = result[i + 1];
      }
    }
    result[result.length - 1] = newPoint;
  }

  return result;
}
