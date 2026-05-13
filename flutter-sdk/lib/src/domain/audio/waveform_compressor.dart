// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';

// Streaming max-pool compressor with doubling stride. Each new sample
// is folded into the current bin using max-pooling. When the buffer
// fills, adjacent bins are pairwise merged so the older half of the
// recording lives in the first half of the buffer and the stride for
// new samples doubles. Memory stays O(binCount) regardless of recording
// length, and the final waveform spans the entire recording uniformly.
class WaveformCompressor {
  final int binCount;
  final double defaultValue;
  late List<double> _bins;
  int _writeIdx = 0;
  int _stride = 1;
  int _countInBin = 0;
  bool _currentBinHasData = false;

  WaveformCompressor({required this.binCount, this.defaultValue = 0.0}) {
    _bins = List<double>.filled(binCount, defaultValue);
  }

  void pushSample(double sample) {
    if (binCount <= 0) {
      return;
    }
    if (!_currentBinHasData || sample > _bins[_writeIdx]) {
      _bins[_writeIdx] = sample;
      _currentBinHasData = true;
    }
    _countInBin++;
    if (_countInBin < _stride) {
      return;
    }
    _countInBin = 0;
    _writeIdx++;
    _currentBinHasData = false;
    if (_writeIdx < binCount) {
      return;
    }
    _halve();
  }

  List<double> snapshot() {
    final filled = _writeIdx + (_currentBinHasData ? 1 : 0);
    if (filled <= 0 || filled >= binCount) {
      return List<double>.from(_bins);
    }
    final result = List<double>.filled(binCount, defaultValue);
    for (var i = 0; i < binCount; i++) {
      result[i] = _bins[(i * filled) ~/ binCount];
    }
    return result;
  }

  void reset() {
    _bins = List<double>.filled(binCount, defaultValue);
    _writeIdx = 0;
    _stride = 1;
    _countInBin = 0;
    _currentBinHasData = false;
  }

  void _halve() {
    final half = binCount ~/ 2;
    for (var i = 0; i < half; i++) {
      _bins[i] = max(_bins[2 * i], _bins[2 * i + 1]);
    }
    for (var i = half; i < binCount; i++) {
      _bins[i] = defaultValue;
    }
    _writeIdx = half;
    _stride *= 2;
    _currentBinHasData = false;
  }
}
