// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/use_cases/audio/audio_processing_use_case.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:clock/clock.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

class MockAudioUseCase extends Mock implements AudioProcessingUseCase {}

void main() {
  group(AudioBloc, () {
    late AudioRepository audioRepository;
    late AudioProcessingUseCase audioUseCase;

    setUp(() {
      audioRepository = MockAudioRepository();
      audioUseCase = MockAudioUseCase();
    });

    group('completed audio subscription', () {
      blocTest<AudioBloc, AudioState>(
        'should stop playing audio (have the playing audio in null) when a completed audio event is received',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          Stream<void> completedStream = Stream.fromIterable([null]);
          when(
            () => audioRepository.onAudioCompleted(),
          ).thenAnswer((_) => completedStream);

          bloc.add(AudioCompletedSubscribe());
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.playingMessage,
                'playing message',
                equals(null),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                equals(AudioStatus.initial),
              ),
        ],
      );
    });

    group('playing audio', () {
      blocTest<AudioBloc, AudioState>(
        'should start playing audio correctly when no other audio is being played',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.playAudio('test.wav'),
          ).thenAnswer((_) async => Result.ok(Unit()));

          bloc.add(
            AudioPlay(
              message: ChatMessage.voice(
                id: 1,
                role: MessageRole.user,
                timestamp: clock.now(),
                fileName: 'test.wav',
                amplitudes: [-34.0, -44.0],
                duration: 2,
              ),
            ),
          );
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.playingMessage,
                'playing message',
                isA<ChatMessage>().having(
                  (msg) => msg.fileName,
                  'file name',
                  equals('test.wav'),
                ),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                equals(AudioStatus.playingAudio),
              ),
        ],
      );

      blocTest<AudioBloc, AudioState>(
        'should start playing audio correctly and stop previous audio if an audio was already being played',
        build: () => AudioBloc(audioRepository: audioRepository),
        seed: () => AudioState(
          playingMessage: ChatMessage.voice(
            id: 1,
            role: MessageRole.user,
            timestamp: clock.now(),
            fileName: 'test.wav',
            amplitudes: [-34.0, -44.0],
            duration: 2,
          ),
        ),
        act: (bloc) {
          when(
            () => audioRepository.pauseAudio(),
          ).thenAnswer((_) async => Result.ok(Unit()));
          when(
            () => audioRepository.playAudio('test2.wav'),
          ).thenAnswer((_) async => Result.ok(Unit()));

          bloc.add(
            AudioPlay(
              message: ChatMessage.voice(
                id: 2,
                role: MessageRole.user,
                timestamp: clock.now(),
                fileName: 'test2.wav',
                amplitudes: [-34.0, -44.0],
                duration: 2,
              ),
            ),
          );
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.playingMessage,
                'playing message',
                equals(null),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                equals(AudioStatus.audioPaused),
              ),
          isA<AudioState>()
              .having(
                (state) => state.playingMessage,
                'playing message',
                isA<ChatMessage>().having(
                  (msg) => msg.fileName,
                  'file name',
                  equals('test2.wav'),
                ),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                equals(AudioStatus.playingAudio),
              ),
        ],
      );

      blocTest<AudioBloc, AudioState>(
        'should not emit anything when an invalid message is sent',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          bloc.add(
            AudioPlay(
              message: ChatMessage(
                id: 2,
                type: MessageType.text,
                role: MessageRole.user,
                timestamp: clock.now(),
              ),
            ),
          );
        },
        expect: () => [],
      );

      blocTest<AudioBloc, AudioState>(
        'should try to play audio even when the pause fails (since the library should handle it too), should also emit a pause error status',
        build: () => AudioBloc(audioRepository: audioRepository),
        seed: () => AudioState(
          playingMessage: ChatMessage.voice(
            id: 1,
            role: MessageRole.user,
            timestamp: clock.now(),
            fileName: 'test.wav',
            amplitudes: [-34.0, -44.0],
            duration: 2,
          ),
        ),
        act: (bloc) {
          when(
            () => audioRepository.pauseAudio(),
          ).thenAnswer((_) async => Result.error(Exception('test exception')));
          when(
            () => audioRepository.playAudio('test2.wav'),
          ).thenAnswer((_) async => Result.ok(Unit()));

          bloc.add(
            AudioPlay(
              message: ChatMessage.voice(
                id: 2,
                role: MessageRole.user,
                timestamp: clock.now(),
                fileName: 'test2.wav',
                amplitudes: [-34.0, -44.0],
                duration: 2,
              ),
            ),
          );
        },
        expect: () => [
          isA<AudioState>().having(
            (state) => state.audioStatus,
            'audio status',
            equals(AudioStatus.errorStoppingAudio),
          ),
          isA<AudioState>()
              .having(
                (state) => state.playingMessage,
                'playing message',
                isA<ChatMessage>().having(
                  (msg) => msg.fileName,
                  'file name',
                  equals('test2.wav'),
                ),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                equals(AudioStatus.playingAudio),
              ),
        ],
      );

      blocTest<AudioBloc, AudioState>(
        'should emit two errors when the play audio error fails and when the pause also fails',
        build: () => AudioBloc(audioRepository: audioRepository),
        seed: () => AudioState(
          playingMessage: ChatMessage.voice(
            id: 1,
            role: MessageRole.user,
            timestamp: clock.now(),
            fileName: 'test.wav',
            amplitudes: [-34.0, -44.0],
            duration: 2,
          ),
        ),
        act: (bloc) {
          when(
            () => audioRepository.pauseAudio(),
          ).thenAnswer((_) async => Result.error(Exception('test exception')));
          when(
            () => audioRepository.playAudio('test2.wav'),
          ).thenAnswer((_) async => Result.error(Exception('test fail')));

          bloc.add(
            AudioPlay(
              message: ChatMessage.voice(
                id: 2,
                role: MessageRole.user,
                timestamp: clock.now(),
                fileName: 'test2.wav',
                amplitudes: [-34.0, -44.0],
                duration: 2,
              ),
            ),
          );
        },
        expect: () => [
          isA<AudioState>().having(
            (state) => state.audioStatus,
            'audio status',
            equals(AudioStatus.errorStoppingAudio),
          ),
          isA<AudioState>().having(
            (state) => state.audioStatus,
            'audio status',
            equals(AudioStatus.errorPlayingAudio),
          ),
        ],
      );
    });

    group('stop recording', () {
      blocTest<AudioBloc, AudioState>(
        'should emit isUserRecordingAudio to false if it stops correctly',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.stopRecording(),
          ).thenAnswer((_) async => Result.ok(Unit()));
          bloc.add(AudioStopRecording());
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.isUserRecordingAudio,
                'is user recording audio',
                equals(false),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                AudioStatus.initial,
              ),
        ],
      );

      blocTest<AudioBloc, AudioState>(
        'should emit an error stopping recording status when it was unable to stop recording',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.stopRecording(),
          ).thenAnswer((_) async => Result.error(Exception('test error')));
          bloc.add(AudioStopRecording());
        },
        expect: () => [
          isA<AudioState>().having(
            (state) => state.audioStatus,
            'audio status',
            AudioStatus.errorStoppingRecording,
          ),
        ],
      );
    });

    group('stop audio', () {
      blocTest<AudioBloc, AudioState>(
        'should emit playing message to null when audio is stopped correctly',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.pauseAudio(),
          ).thenAnswer((_) async => Result.ok(Unit()));
          bloc.add(AudioStop());
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.playingMessage,
                'playing message',
                equals(null),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                AudioStatus.initial,
              ),
        ],
      );

      blocTest<AudioBloc, AudioState>(
        'should emit error stopping audio status audio when it fails to stop audio',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.pauseAudio(),
          ).thenAnswer((_) async => Result.error(Exception('error')));
          bloc.add(AudioStop());
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.isUserRecordingAudio,
                'is user recording audio',
                equals(false),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                AudioStatus.errorStoppingAudio,
              ),
        ],
      );
    });

    group('on amplitude subscribe', () {
      blocTest<AudioBloc, AudioState>(
        'should emit correctly',
        build: () => AudioBloc(
          audioRepository: audioRepository,
          audioUseCase: audioUseCase,
        ),
        seed: () => AudioState(
          amplitudes: [-30, -30],
          amplitudeIndex: 2,
          millisecondsRecording: 0,
        ),
        act: (bloc) {
          Stream<double> amplitudeStream = Stream.fromIterable([
            -3.0,
            -160.0,
            -6.9,
          ]);
          when(
            () => audioRepository.getAmplitudes(
              Duration(milliseconds: AudioBloc.recordTickMs),
            ),
          ).thenAnswer((_) => amplitudeStream);
          when(
            () => audioUseCase.compressWaveformForPreview(any(), any(), any()),
          ).thenReturn([-3.0, -160.0]);
          bloc.add(AudioAmplitudeSubscribe());
        },
        expect: () => [
          AudioState(
            amplitudes: [-30, -3.0],
            amplitudeIndex: 1,
            amplitudesFilePreview: [-3.0, -160.0],
            millisecondsRecording: AudioBloc.recordTickMs,
          ),
          AudioState(
            amplitudes: [-3.0, -160.0],
            amplitudeIndex: 0,
            amplitudesFilePreview: [-3.0, -160.0],
            millisecondsRecording: AudioBloc.recordTickMs * 2,
          ),
          AudioState(
            amplitudes: [-160.0, -6.9],
            amplitudeIndex: 1,
            amplitudesFilePreview: [-3.0, -160.0],
            millisecondsRecording: AudioBloc.recordTickMs * 3,
          ),
        ],
      );
    });

    group('start recording', () {
      blocTest<AudioBloc, AudioState>(
        'Should start recording successfully when no error is returned',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.recordAudio(),
          ).thenAnswer((_) async => Result.ok('test-file-name.wav'));

          bloc.add(AudioStartRecording());
        },
        expect: () => [
          AudioState(
            isUserRecordingAudio: true,
            audioFileName: 'test-file-name.wav',
            amplitudeIndex: AudioBloc.amplitudeDataPoints - 1,
            amplitudes: List<double>.filled(
              AudioBloc.amplitudeDataPoints,
              AudioBloc.defaultAmplitude,
            ),
            amplitudesFilePreview: List<double>.filled(
              AudioBloc.amplitudeDataPoints,
              AudioBloc.defaultAmplitude,
            ),
            millisecondsRecording: 0,
          ),
        ],
      );

      blocTest<AudioBloc, AudioState>(
        'should emit userRecordingAudio false and error recording audio when start recording fails',
        build: () => AudioBloc(audioRepository: audioRepository),
        act: (bloc) {
          when(
            () => audioRepository.recordAudio(),
          ).thenAnswer((_) async => Result.error(Exception('test exception')));

          bloc.add(AudioStartRecording());
        },
        expect: () => [
          isA<AudioState>()
              .having(
                (state) => state.isUserRecordingAudio,
                'is user recording',
                equals(false),
              )
              .having(
                (state) => state.audioStatus,
                'audio status',
                equals(AudioStatus.errorRecordingAudio),
              ),
        ],
      );
    });
  });
}
