// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_flutter_sdk/src/common/exceptions/permission_exception.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service_file.dart';
import 'package:mocktail/mocktail.dart';
import 'package:record/record.dart';
import 'package:test/test.dart';

class MockAudioRecorder extends Mock implements AudioRecorder {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

void main() {
  group(AudioServiceFile, () {
    late AudioRecorder audioRecorder;
    late AudioPlayer audioPlayer;
    late AudioService audioService;
    setUp(() {
      audioRecorder = MockAudioRecorder();
      audioPlayer = MockAudioPlayer();
      audioService = AudioServiceFile(audioRecorder, audioPlayer);
    });

    setUpAll(() {
      registerFallbackValue(RecordConfig());
      registerFallbackValue(AudioEncoder.wav);
      registerFallbackValue(DeviceFileSource('test'));
    });
    group('recording', () {
      test('should start recording when permissions exist', () async {
        when(() => audioRecorder.hasPermission()).thenAnswer((_) async => true);
        when(
          () => audioRecorder.start(any(), path: any(named: 'path')),
        ).thenAnswer((_) async => ());

        final result = await audioService.record('testpath', AudioEncoding.wav);
        expect(result, isA<Ok<Unit>>());
      });

      test('should return an error when starting the record fails', () async {
        when(() => audioRecorder.hasPermission()).thenAnswer((_) async => true);
        when(
          () => audioRecorder.start(any(), path: any(named: 'path')),
        ).thenThrow(Exception('test exception'));

        final result = await audioService.record('testpath', AudioEncoding.wav);
        expect(result, isA<Error<Unit>>());
      });

      test(
        'should return an error when no recording permissions exists',
        () async {
          when(
            () => audioRecorder.hasPermission(),
          ).thenAnswer((_) async => false);

          final result = await audioService.record(
            'testpath',
            AudioEncoding.wav,
          );
          expect(
            result,
            isA<Error<Unit>>().having(
              (e) => e.error,
              'error',
              isA<PermissionException>(),
            ),
          );
        },
      );
    });

    group('stop recording', () {
      test('should stop recording without errors', () async {
        when(() => audioRecorder.stop()).thenAnswer((_) async => 'testpath');

        final result = await audioService.stopRecord();
        expect(result, isA<Ok<Unit>>());
      });

      test('should return an error when stopping recording fails', () async {
        when(() => audioRecorder.stop()).thenThrow(Exception('test exception'));
        final result = await audioService.stopRecord();
        expect(result, isA<Error<Unit>>());
      });
    });

    group('amplitude stream', () {
      test('should return a amplitude stream with only doubles', () async {
        Stream<Amplitude> mockStream = Stream.fromIterable([
          Amplitude(current: -10.0, max: 0.0),
          Amplitude(current: -15.0, max: 0.0),
        ]);

        when(
          () => audioRecorder.onAmplitudeChanged(Duration(milliseconds: 200)),
        ).thenAnswer((_) => mockStream);

        final result = audioService.getAmplitudeStream(
          Duration(milliseconds: 200),
        );

        final values = await result.take(2).toList();
        expect(values, equals([-10.0, -15.0]));
      });
    });

    group('dispose', () {
      test('should free all the resources', () async {
        when(() => audioRecorder.dispose()).thenAnswer((_) async => ());
        when(() => audioPlayer.dispose()).thenAnswer((_) async => ());
        await audioService.dispose();

        verify(() => audioRecorder.dispose()).called(1);
        verify(() => audioPlayer.dispose()).called(1);
      });
    });

    group('play audio', () {
      test('should play audio without errors', () async {
        when(() => audioPlayer.play(any())).thenAnswer((_) async => ());

        final result = await audioService.playAudio('test-path');
        expect(result, isA<Ok<Unit>>());
      });

      test('should return an error when play audio fails', () async {
        when(() => audioPlayer.play(any())).thenThrow(Exception('test error'));
        final result = await audioService.playAudio('test-path');
        expect(result, isA<Error<Unit>>());
      });
    });

    group('play audio', () {
      test('should pause audio without errors', () async {
        when(() => audioPlayer.pause()).thenAnswer((_) async => ());

        final result = await audioService.pauseAudio();
        expect(result, isA<Ok<Unit>>());
      });

      test('should return an error when pausing audio fails', () async {
        when(() => audioPlayer.pause()).thenThrow(Exception('test error'));
        final result = await audioService.pauseAudio();
        expect(result, isA<Error<Unit>>());
      });
    });

    group('on audio completed', () {
      test('should return a completion void stream ', () async {
        Stream<void> mockStream = Stream.fromIterable([null, null]);

        when(() => audioPlayer.onPlayerComplete).thenAnswer((_) => mockStream);

        final result = audioService.onAudioCompleted();

        final values = await result.take(2).toList();
        expect(values, equals([null, null]));
      });
    });

    test('should create a service with default parameters', () {
      final service = AudioServiceFile();
      expect(service, isA<AudioServiceFile>());
      service.dispose();
    });
  });
}
