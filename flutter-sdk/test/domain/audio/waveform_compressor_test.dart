// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/src/domain/audio/waveform_compressor.dart';
import 'package:test/test.dart';

void pushAll(WaveformCompressor compressor, List<double> samples) {
  for (final sample in samples) {
    compressor.pushSample(sample);
  }
}

void main() {
  group(WaveformCompressor, () {
    test('starts with a default filled buffer of the requested size', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      expect(compressor.snapshot(), equals([-30, -30, -30, -30]));
    });

    test('stretches a short recording across the full buffer so the tail does not stay flat', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      pushAll(compressor, [-3.0, -20.0]);

      expect(compressor.snapshot(), equals([-3.0, -3.0, -20.0, -20.0]));
    });

    test('returns a flat preview at the level of the only sample when a single sample has been pushed', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      compressor.pushSample(-10);

      expect(compressor.snapshot(), equals([-10, -10, -10, -10]));
    });

    test('compacts older samples and doubles the stride when the buffer fills', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      pushAll(compressor, [-3.0, -10.0, -20.0, -5.0, -8.0]);

      expect(compressor.snapshot(), equals([-3.0, -3.0, -5.0, -8.0]));
    });

    test('keeps the loudest sample of each merged bin pair when halving', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      pushAll(compressor, [-10.0, -3.0, -20.0, -8.0, -50.0, -15.0]);

      expect(compressor.snapshot(), equals([-3.0, -3.0, -8.0, -15.0]));
    });

    test('preserves the overall waveform shape across the full recording', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -160);

      pushAll(compressor, [
        ...List<double>.filled(64, -3.0),
        ...List<double>.filled(64, -100.0),
        ...List<double>.filled(64, -10.0),
        ...List<double>.filled(63, -50.0),
      ]);

      expect(compressor.snapshot(), equals([-3.0, -100.0, -10.0, -50.0]));
    });

    test('keeps memory bounded regardless of how many samples are pushed', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      for (var i = 0; i < 10000; i++) {
        compressor.pushSample(-30.0);
      }

      expect(compressor.snapshot(), hasLength(4));
    });

    test('replaces the default when the first sample in a bin is quieter than the default', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);

      compressor.pushSample(-100);

      expect(compressor.snapshot()[0], equals(-100));
    });

    test('clears the buffer and rewinds the stride on reset', () {
      final compressor = WaveformCompressor(binCount: 4, defaultValue: -30);
      pushAll(compressor, [-3.0, -10.0, -20.0, -5.0, -8.0]);

      compressor.reset();

      expect(compressor.snapshot(), equals([-30, -30, -30, -30]));
    });
  });
}
