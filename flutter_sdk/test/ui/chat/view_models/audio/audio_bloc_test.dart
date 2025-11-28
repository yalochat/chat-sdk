// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAudioRepository extends Mock implements AudioRepository {}

void main() {
  group(AudioBloc, () {
    late final AudioRepository audioRepository;

    setUp(() {
      audioRepository = MockAudioRepository();
    });

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
        isA<AudioState>().having(
          (state) => state.playingMessage,
          'playing message',
          equals(null),
        ),
      ],
    );

    blocTest<AudioBloc, AudioState>(
      'should start playing audio correctly when no other audio is being played',
      build: () => AudioBloc(audioRepository: audioRepository),
      act: (bloc) {
        Stream<void> completedStream = Stream.fromIterable([null]);
        when(
          () => audioRepository.onAudioCompleted(),
        ).thenAnswer((_) => completedStream);

        bloc.add(AudioCompletedSubscribe());
      },
      expect: () => [
        isA<AudioState>().having(
          (state) => state.playingMessage,
          'playing message',
          equals(null),
        ),
      ],
    );
    
  });
}
