// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:test/test.dart';

void main() {
  group('AudioData', () {
    test('creates instance with default values', () {
      final audioData = AudioData();

      expect(audioData.fileName, equals(''));
      expect(audioData.amplitudes, equals([]));
      expect(audioData.amplitudesFilePreview, equals([]));
      expect(audioData.duration, equals(0));
    });

    test('creates instance with provided values', () {
      final amplitudes = [1.0, 2.0, 3.0];
      final amplitudesFilePreview = [0.5, 1.5];
      final audioData = AudioData(
        fileName: 'test.mp3',
        amplitudes: amplitudes,
        amplitudesFilePreview: amplitudesFilePreview,
        duration: 5000,
      );

      expect(audioData.fileName, equals('test.mp3'));
      expect(audioData.amplitudes, equals(amplitudes));
      expect(audioData.amplitudesFilePreview, equals(amplitudesFilePreview));
      expect(audioData.duration, equals(5000));
    });

    test('copyWith returns new instance with updated values', () {
      final original = AudioData(
        fileName: 'original.mp3',
        amplitudes: [1.0, 2.0],
        duration: 3000,
      );

      final copied = original.copyWith(fileName: 'copied.mp3', duration: 4000);

      expect(copied.fileName, equals('copied.mp3'));
      expect(copied.amplitudes, equals([1.0, 2.0]));
      expect(copied.duration, equals(4000));
      expect(original.fileName, equals('original.mp3'));
    });

    test('copyWith with null values keeps original values', () {
      final original = AudioData(
        fileName: 'test.mp3',
        amplitudes: [1.0, 2.0],
        duration: 3000,
      );

      final copied = original.copyWith();

      expect(copied.fileName, equals(original.fileName));
      expect(copied.amplitudes, equals(original.amplitudes));
      expect(copied.duration, equals(original.duration));
    });

    test('equality works correctly', () {
      final audioData1 = AudioData(
        fileName: 'test.mp3',
        amplitudes: [1.0, 2.0],
        duration: 3000,
      );

      final audioData2 = AudioData(
        fileName: 'test.mp3',
        amplitudes: [1.0, 2.0],
        duration: 3000,
      );

      final audioData3 = AudioData(
        fileName: 'different.mp3',
        amplitudes: [1.0, 2.0],
        duration: 3000,
      );

      expect(audioData1, equals(audioData2));
      expect(audioData1, isNot(equals(audioData3)));
    });

    test('handles null amplitudes in constructor', () {
      final audioData = AudioData(
        fileName: 'test.mp3',
        amplitudes: null,
        amplitudesFilePreview: null,
      );

      expect(audioData.amplitudes, equals([]));
      expect(audioData.amplitudesFilePreview, equals([]));
    });
  });
}
