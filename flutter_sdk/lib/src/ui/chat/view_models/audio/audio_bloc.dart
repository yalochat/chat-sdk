// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/use_cases/audio/audio_processing_use_case.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  @visibleForTesting
  static const int recordTickMs = 45;
  @visibleForTesting
  static const int amplitudeDataPoints = 48;
  @visibleForTesting
  static const double defaultAmplitude = -30;
  final AudioRepository _audioRepository;
  final AudioProcessingUseCase _audioUseCase;
  final Logger log = Logger('AudioViewModel');
  AudioBloc({
    required AudioRepository audioRepository,
    AudioProcessingUseCase? audioUseCase,
  }) : _audioRepository = audioRepository,
       _audioUseCase = audioUseCase ?? AudioProcessingUseCase(),
       super(
         AudioState(
           audioData: AudioData(
             amplitudes: List<double>.filled(
               amplitudeDataPoints,
               defaultAmplitude,
             ),
             amplitudesFilePreview: List<double>.filled(
               amplitudeDataPoints,
               defaultAmplitude,
             ),
           ),
           amplitudeIndex: amplitudeDataPoints - 1,
         ),
       ) {
    on<AudioCompletedSubscribe>(_handleAudioCompletedSubscribe);
    on<AudioPlay>(_handlePlayAudio);
    on<AudioStop>(_handleStopAudio);
    on<AudioAmplitudeSubscribe>(_onAmplitudeSubscribe);
    on<AudioStartRecording>(_handleStartRecording);
    on<AudioStopRecording>(_handleStopRecording);
  }

  // Handles the event when an audio has been played completely
  Future<void> _handleAudioCompletedSubscribe(
    AudioCompletedSubscribe event,
    Emitter<AudioState> emit,
  ) async {
    log.info('Subscribing to audio completion stream');
    final stream = _audioRepository.onAudioCompleted();

    await emit.forEach(
      stream,
      onData: (_) {
        log.fine('Audio completion event received');
        return state.copyWith(
          playingMessage: () => null,
          audioStatus: AudioStatus.initial,
        );
      },
    );
  }

  // Handles the event when an audio is played, stops all other audios from playing first (if there's any)
  Future<void> _handlePlayAudio(
    AudioPlay event,
    Emitter<AudioState> emit,
  ) async {
    if (event.message.type != MessageType.voice ||
        event.message.fileName == null ||
        event.message.fileName == '') {
      log.warning(
        'No message was played because a non voice message was passed',
      );
      return;
    }

    log.info('Trying to play audio ${event.message.fileName}');
    if (state.playingMessage != null) {
      log.info('Stopping currently playing message');
      final resultPause = await _audioRepository.pauseAudio();
      switch (resultPause) {
        case Ok():
          log.info('Pause previous audio succeeded');
          emit(
            state.copyWith(
              playingMessage: () => null,
              audioStatus: AudioStatus.audioPaused,
            ),
          );
          break;
        case Error():
          log.severe('Unable to stop audio from playing', resultPause.error);
          emit(state.copyWith(audioStatus: AudioStatus.errorStoppingAudio));
          break;
      }
    }
    final result = await _audioRepository.playAudio(event.message.fileName!);
    switch (result) {
      case Ok():
        log.info('Playing audio succeeded');
        emit(
          state.copyWith(
            playingMessage: () => event.message,
            audioStatus: AudioStatus.playingAudio,
          ),
        );
        break;
      case Error():
        log.severe('Unable to play audio', result.error);
        emit(state.copyWith(audioStatus: AudioStatus.errorPlayingAudio));
        break;
    }
  }

  // Handles the event to stop recording
  Future<void> _handleStopRecording(
    AudioStopRecording event,
    Emitter<AudioState> emit,
  ) async {
    log.info('Stopping recording');
    final result = await _audioRepository.stopRecording();
    switch (result) {
      case Ok():
        log.info('Recording stopped successfully');
        emit(
          state.copyWith(
            isUserRecordingAudio: false,
            audioStatus: AudioStatus.initial,
          ),
        );
        break;
      case Error():
        log.info('Unable to stop recording');
        emit(state.copyWith(audioStatus: AudioStatus.errorStoppingRecording));
        break;
    }
  }

  // Handles the event when a user stops a voice note play
  Future<void> _handleStopAudio(
    AudioStop event,
    Emitter<AudioState> emit,
  ) async {
    final result = await _audioRepository.pauseAudio();
    switch (result) {
      case Ok():
        log.info('Audio stopped correctly');
        emit(
          state.copyWith(
            playingMessage: () => null,
            audioStatus: AudioStatus.initial,
          ),
        );
        break;
      case Error():
        log.severe('Unable to stop audio', result.error);
        emit(state.copyWith(audioStatus: AudioStatus.errorStoppingAudio));
        break;
    }
  }

  // Subscribes to amplitude stream when a user starts recording
  Future<void> _onAmplitudeSubscribe(
    AudioAmplitudeSubscribe event,
    Emitter<AudioState> emit,
  ) async {
    final amplitudesStream = _audioRepository.getAmplitudes(
      Duration(milliseconds: recordTickMs),
    );

    await emit.forEach(
      amplitudesStream,
      onData: (data) {
        assert(!data.isInfinite, 'no infinity values allowed');
        final maxPoints = state.audioData.amplitudes.length;
        final millisecondsRecording = state.audioData.duration + recordTickMs;
        assert(
          millisecondsRecording % recordTickMs == 0,
          'Milliseconds must be a multiple of _recordTickMs',
        );
        final wavePreview = _audioUseCase.compressWaveformForPreview(
          data,
          millisecondsRecording ~/ recordTickMs,
          state.audioData.amplitudesFilePreview,
        );

        return state.copyWith(
          audioData: state.audioData.copyWith(
            amplitudes: state.audioData.amplitudes.sublist(1)..add(data),
            amplitudesFilePreview: wavePreview,
            duration: millisecondsRecording,
          ),
          // Create an animation of the waves sliding.
          amplitudeIndex: (state.amplitudeIndex - 1) % maxPoints,
        );
      },
    );
  }

  // Handles the event to start a recording session
  Future<void> _handleStartRecording(
    AudioStartRecording event,
    Emitter<AudioState> emit,
  ) async {
    log.info('Trying to record audio');
    final audioStreamResult = await _audioRepository.recordAudio();
    switch (audioStreamResult) {
      case Ok():
        log.info(
          'Audio started successfully with file ${audioStreamResult.result}',
        );
        emit(
          state.copyWith(
            isUserRecordingAudio: true,
            audioData: AudioData(
              fileName: audioStreamResult.result,
              amplitudes: List<double>.filled(
                amplitudeDataPoints,
                defaultAmplitude,
              ),
              amplitudesFilePreview: List<double>.filled(
                amplitudeDataPoints,
                defaultAmplitude,
              ),
              duration: 0,
            ),
            amplitudeIndex: state.audioData.amplitudes.length - 1,
          ),
        );
        break;
      case Error():
        log.severe('Unable to start audio recording', audioStreamResult.error);
        emit(
          state.copyWith(
            isUserRecordingAudio: false,
            audioStatus: AudioStatus.errorRecordingAudio,
          ),
        );
        break;
    }
  }
}
