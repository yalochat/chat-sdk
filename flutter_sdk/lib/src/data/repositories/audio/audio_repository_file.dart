// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service.dart';
import 'package:uuid/uuid.dart';
import 'audio_repository.dart';

// Implementation of an audio repository, stores audio data in files and provides
// a stream for live drawing
class AudioRepositoryFile implements AudioRepository {
  final AudioService _audioService;
  final Future<Directory> Function() _directory;
  final Uuid _uuid;

  AudioRepositoryFile(
    AudioService audioService,
    Future<Directory> Function() directory,
    [Uuid? uuid]
  ) : _audioService = audioService,
      _directory = directory,
      _uuid = uuid ?? Uuid();

  @override
  Future<Result<String>> recordAudio() async {
    final directory = await _directory();

    var audioName = _uuid.v4();
    var fileName = '${directory.path}/$audioName.wav';

    final result = await _audioService.record(fileName, AudioEncoding.wav);
    return switch (result) {
      Ok() => Result.ok(fileName),
      Error() => Result.error(result.error),
    };
  }

  @override
  Future<Result<Unit>> stopRecording() async => _audioService.stopRecord();

  @override
  Stream<double> getAmplitudes(Duration duration) => _audioService
      .getAmplitudeStream(duration)
      .map((amp) => amp.isInfinite ? -160.0 : amp)
      .asBroadcastStream();

  @override
  Future<Result<Unit>> playAudio(String path) => _audioService.playAudio(path);

  @override
  Future<Result<Unit>> pauseAudio() => _audioService.pauseAudio();

  @override
  Stream<void> onAudioCompleted() => _audioService.onAudioCompleted();
}
