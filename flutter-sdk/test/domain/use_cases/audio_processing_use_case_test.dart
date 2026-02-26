// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/use_cases/audio/audio_processing_use_case.dart';
import 'package:test/test.dart';

void main() {
  group(AudioProcessingUseCase, () {
    late AudioProcessingUseCase audioProcessingUseCase;

    setUp(() {
      audioProcessingUseCase = AudioProcessingUseCase();
    });

    test('should keep maximum points across the array', () {
      List<double> amplitudePreview = [
        0.0,
        -160.0,
        for (int i = 0; i < 200; i++) -30.0,
        -3.0,
        -4.0,
        for (int i = 0; i < 500; i++) -30.0,
        -5.0,
        -160.0,
      ];

      var totalSamples = amplitudePreview.length;
      for (int i = 0; i < 1000; i++) {
        amplitudePreview = audioProcessingUseCase.compressWaveformForPreview(
          -70,
          totalSamples,
          amplitudePreview,
        );
        totalSamples++;
      }

      expect(amplitudePreview, containsAll([0.0, -3.0, -4.0, -5.0]));
      var find3Index = amplitudePreview.indexOf(-3.0);
      var find4Index = amplitudePreview.indexOf(-4.0);
      var find5Index = amplitudePreview.indexOf(-5.0);

      expect(find3Index < find4Index && find4Index < find5Index, equals(true));
    });
  });
}
