// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'audio_event.dart';
import 'audio_state.dart';

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  static const int _recordTickMs = 45;
  static const int _amplitudeDataPoints = 48;
  static const double _defaultAmplitude = -30;
  final AudioRepository _audioRepository;
  final Logger log = Logger('AudioViewModel');
  AudioBloc({required AudioRepository audioRepository})
    : _audioRepository = audioRepository,
      super(
        AudioState(
          amplitudes: List<double>.filled(
            _amplitudeDataPoints,
            _defaultAmplitude,
          ),
          amplitudesFilePreview: List<double>.filled(
            _amplitudeDataPoints,
            _defaultAmplitude,
          ),
          amplitudeIndex: _amplitudeDataPoints - 1,
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
        return state.copyWith(playingMessage: () => null);
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
          emit(state.copyWith(playingMessage: () => null));
          break;
        case Error():
          log.severe('Unable to stop audio from playing', resultPause.error);
          break;
      }
    }
    final result = await _audioRepository.playAudio(event.message.fileName!);
    switch (result) {
      case Ok():
        log.info('Playing audio succeeded');
        emit(state.copyWith(playingMessage: () => event.message));
        break;
      case Error():
        log.severe('Unable to play audio', result.error);
        break;
    }
  }

  // Handles the event to stop recording
  Future<void> _handleStopRecording(
    AudioStopRecording event,
    Emitter<AudioState> emit,
  ) async {
    final result = await _audioRepository.stopRecording();
    switch (result) {
      case Ok():
        emit(state.copyWith(isUserRecordingAudio: false));
        break;
      case Error():
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
        emit(state.copyWith(playingMessage: () => null));
        break;
      case Error():
        log.severe('Unable to stop audio', result.error);
        break;
    }
  }

  // Method that compresses the amplitudes to fixed size array keeping only maximums
  List<double> _calculateAmplitudeFilePreview(
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

  // Subscribes to amplitude stream when a user starts recording
  Future<void> _onAmplitudeSubscribe(
    AudioAmplitudeSubscribe event,
    Emitter<AudioState> emit,
  ) async {
    final amplitudesStream = _audioRepository.getAmplitudes(
      Duration(milliseconds: _recordTickMs),
    );
    await emit.forEach(
      amplitudesStream,
      onData: (data) {
        assert(!data.isInfinite, 'no infinity values allowed');
        final maxPoints = state.amplitudes.length;
        final millisecondsRecording =
            state.millisecondsRecording + _recordTickMs;
        assert(
          millisecondsRecording % _recordTickMs == 0,
          'Milliseconds must be a multiple of _recordTickMs',
        );
        return state.copyWith(
          // Create an animation of the waves sliding.
          amplitudes: state.amplitudes.sublist(1)..add(data),
          amplitudeIndex: (state.amplitudeIndex - 1) % maxPoints,
          amplitudesFilePreview: _calculateAmplitudeFilePreview(
            data,
            millisecondsRecording ~/ _recordTickMs,
            state.amplitudesFilePreview,
          ),
          millisecondsRecording: millisecondsRecording,
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
            audioFileName: audioStreamResult.result,
            amplitudeIndex: state.amplitudes.length - 1,
            amplitudes: List<double>.filled(
              _amplitudeDataPoints,
              _defaultAmplitude,
            ),
            amplitudesFilePreview: List<double>.filled(
              _amplitudeDataPoints,
              _defaultAmplitude,
            ),
            millisecondsRecording: 0,
          ),
        );
        break;
      case Error():
        emit(
          state.copyWith(
            audioFileName: '',
            isUserRecordingAudio: false,
          ),
        );
        break;
    }
  }
}
