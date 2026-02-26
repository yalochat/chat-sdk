// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository_local.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service.dart';

class MockAudioService extends Mock implements AudioService {}

class MockUuid extends Mock implements Uuid {}

void main() {
  group(AudioRepositoryLocal, () {
    late MockAudioService mockAudioService;
    late MockUuid mockUuid;
    late AudioRepositoryLocal repository;
    late Future<Directory> Function() directoryProvider;

    setUpAll(() {
      registerFallbackValue(AudioEncoding.wav);
    });

    setUp(() {
      mockAudioService = MockAudioService();
      mockUuid = MockUuid();
      directoryProvider = () async => Directory('/test/path');

      repository = AudioRepositoryLocal(
        mockAudioService,
        directoryProvider,
        mockUuid,
      );
    });

    group('record audio', () {
      test('should return file path when recording succeeds', () async {
        when(() => mockUuid.v4()).thenReturn('test-uuid-123');
        const expectedPath = '/test/path/test-uuid-123.wav';
        when(
          () => mockAudioService.record(expectedPath, AudioEncoding.wav),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await repository.recordAudio();

        expect(
          result,
          isA<Ok<String>>().having(
            (res) => res.result,
            'result',
            equals(expectedPath),
          ),
        );
      });

      test('should return error when recording fails', () async {
        when(() => mockUuid.v4()).thenReturn('test-uuid-123');

        const expectedPath = '/test/path/test-uuid-123.wav';
        when(
          () => mockAudioService.record(expectedPath, AudioEncoding.wav),
        ).thenAnswer((_) async => Result.error(Exception('test error')));

        final result = await repository.recordAudio();

        expect(result, isA<Error<String>>());
      });

      test('should generate unique filename for each recording', () async {
        when(
          () => mockAudioService.record(any(), any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        when(() => mockUuid.v4()).thenReturn('uuid1');
        await repository.recordAudio();
        when(() => mockUuid.v4()).thenReturn('uuid2');
        await repository.recordAudio();

        verify(
          () => mockAudioService.record(
            '/test/path/uuid1.wav',
            AudioEncoding.wav,
          ),
        ).called(1);
        verify(
          () => mockAudioService.record(
            '/test/path/uuid2.wav',
            AudioEncoding.wav,
          ),
        ).called(1);
      });
    });

    group('stop recording', () {
      test('should stop recording successfully', () async {
        when(
          () => mockAudioService.stopRecord(),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await repository.stopRecording();

        expect(result, isA<Ok<Unit>>());
      });

      test('should return error when stop recording fails', () async {
        when(
          () => mockAudioService.stopRecord(),
        ).thenAnswer((_) async => Result.error(Exception('test error')));

        final result = await repository.stopRecording();

        expect(result, isA<Error<Unit>>());
      });
    });

    group('get amplitudes', () {
      test('should return amplitude stream with finite values', () async {
        const duration = Duration(milliseconds: 100);
        final amplitudeStream = Stream.fromIterable([50.0, 75.0, 30.0]);
        when(
          () => mockAudioService.getAmplitudeStream(duration),
        ).thenAnswer((_) => amplitudeStream);

        final stream = repository.getAmplitudes(duration);
        final amplitudes = await stream.take(3).toList();

        expect(amplitudes, equals([50.0, 75.0, 30.0]));
        verify(() => mockAudioService.getAmplitudeStream(duration)).called(1);
      });

      test('should convert infinite values to -160.0', () async {
        const duration = Duration(milliseconds: 100);
        final amplitudeStream = Stream.fromIterable([
          50.0,
          double.infinity,
          75.0,
          double.negativeInfinity,
        ]);
        when(
          () => mockAudioService.getAmplitudeStream(duration),
        ).thenAnswer((_) => amplitudeStream);

        final stream = repository.getAmplitudes(duration);
        final amplitudes = await stream.take(4).toList();

        expect(amplitudes, equals([50.0, -160.0, 75.0, -160.0]));
      });

      test('should return broadcast stream', () async {
        const duration = Duration(milliseconds: 100);
        final amplitudeStream = Stream.fromIterable([50.0]);
        when(
          () => mockAudioService.getAmplitudeStream(duration),
        ).thenAnswer((_) => amplitudeStream);

        final stream = repository.getAmplitudes(duration);

        expect(stream.isBroadcast, isTrue);
      });
    });

    group('play audio', () {
      test('should play audio with given path', () async {
        const path = '/test/audio.wav';
        when(
          () => mockAudioService.playAudio(path),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await repository.playAudio(path);

        expect(result, isA<Ok<Unit>>());
      });

      test('should return error when play fails', () async {
        const path = '/test/audio.wav';
        when(
          () => mockAudioService.playAudio(path),
        ).thenAnswer((_) async => Result.error(Exception('test error')));

        final result = await repository.playAudio(path);

        expect(result, isA<Error<Unit>>());
      });
    });

    group('pause audio', () {
      test('should delegate to audio service', () async {
        when(
          () => mockAudioService.pauseAudio(),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await repository.pauseAudio();

        expect(result, isA<Result<Unit>>());
      });
    });

    group('on audio completed', () {
      test('should return audio service completion stream', () async {
        final completionStream = Stream.fromIterable([null, null]);
        when(
          () => mockAudioService.onAudioCompleted(),
        ).thenAnswer((_) => completionStream);

        final stream = repository.onAudioCompleted();
        final events = await stream.take(2).toList();

        expect(events.length, equals(2));
      });
    });

    test('should create default Uuid when null is provided', () {
      final repo = AudioRepositoryLocal(mockAudioService, directoryProvider);
      expect(repo, isA<AudioRepositoryLocal>());
    });
  });
}
