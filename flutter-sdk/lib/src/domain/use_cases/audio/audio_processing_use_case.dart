// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';


// Use case that contains business logic that can be
// reused in multiple view models.
class AudioProcessingUseCase {
  // Receives a new point to add to amplitudePreview,
  // recompresses the waveform creating a new waveform preview.
  //
  // Only tries to preserve the maximum data points of the waveform.
  List<double> compressWaveformForPreview(
    double newPoint,
    int totalSamples,
    List<double> amplitudePreview,
  ) {
    final result = [...amplitudePreview];
    final totalBins = amplitudePreview.length;
    if (totalSamples <= totalBins) {
      result[totalSamples - 1] = newPoint;
    } else {
      var targetBin = totalSamples % totalBins;
      for (var i = targetBin; i < result.length - 1; i++) {
        if (i == targetBin) {
          result[i] = max(result[i], result[i + 1]);
        } else {
          result[i] = result[i + 1];
        }
      }
      result.last = newPoint;
    }

    return result;
  }
}
