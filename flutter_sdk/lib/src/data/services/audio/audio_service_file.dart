// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_flutter_sdk/src/common/exceptions/permission_exception.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:logging/logging.dart';
import 'package:record/record.dart';

import 'audio_service.dart';

class AudioServiceFile implements AudioService {
  final Logger log = Logger('CameraService');
  final AudioRecorder _recorder;
  final AudioPlayer _player;

  AudioServiceFile([AudioRecorder? recorder, AudioPlayer? player])
    : _recorder = recorder ?? AudioRecorder(),
      _player = player ?? AudioPlayer();

  @override
  Future<Result<Unit>> record(String path, AudioEncoding encoding) async {
    log.info('Recording audio in path: $path');
    if (!(await _recorder.hasPermission())) {
      log.severe('User did not allow microphone permission');
      return Result.error(PermissionException('recording'));
    }
    final encoder = switch (encoding) {
      AudioEncoding.wav => AudioEncoder.wav,
    };
    try {
      await _recorder.start(RecordConfig(encoder: encoder), path: path);
      log.info('Recording audio started successfully');
      return Result.ok(Unit());
    } on Exception catch (e) {
      log.severe('Unable to record audio', e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> stopRecord() async {
    log.info('Stopping audio recording');
    try {
      await _recorder.stop();
      log.info('Recording stopped successfully');
      return Result.ok(Unit());
    } on Exception catch (e) {
      log.severe('Recording stopped successfully');
      return Result.error(e);
    }
  }

  @override
  Stream<double> getAmplitudeStream(Duration duration) =>
      _recorder.onAmplitudeChanged(duration).map((amp) => amp.current);

  @override
  Future<void> dispose() async {
    await _recorder.dispose();
    await _player.dispose();
  }

  @override
  Future<Result<Unit>> playAudio(String path) async {
    log.info('Playing audio from path $path');
    try {
      await _player.play(DeviceFileSource(path));
      log.info('Playing audio succeeded');
      return Result.ok(Unit());
    } on Exception catch (e) {
      log.severe('Unable to play audio', e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> pauseAudio() async {
    log.info('Pausing current audio');
    try {
      await _player.pause();
      log.info('Pausing audio succeeded');
      return Result.ok(Unit());
    } on Exception catch (e) {
      log.severe('Unable to pause audio');
      return Result.error(e);
    }
  }

  @override
  Stream<void> onAudioCompleted() => _player.onPlayerComplete;
}
