// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:audioplayers/audioplayers.dart';
import 'package:chat_flutter_sdk/src/common/exceptions/permission_exception.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:record/record.dart';

import 'audio_service.dart';

class AudioServiceFile implements AudioService {
  final AudioRecorder _recorder;
  final AudioPlayer _player;

  AudioServiceFile([AudioRecorder? recorder, AudioPlayer? player])
    : _recorder = recorder ?? AudioRecorder(),
      _player = player ?? AudioPlayer();

  @override
  Future<Result<Unit>> record(String path, AudioEncoding encoding) async {
    if (!(await _recorder.hasPermission())) {
      return Result.error(PermissionException('recording'));
    }
    final encoder = switch (encoding) {
      AudioEncoding.wav => AudioEncoder.wav,
    };
    try {
      await _recorder.start(RecordConfig(encoder: encoder), path: path);
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> stopRecord() async {
    try {
      await _recorder.stop();
      return Result.ok(Unit());
    } on Exception catch (e) {
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
    try {
      await _player.play(DeviceFileSource(path));
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> pauseAudio() async {
    try {
      await _player.pause();
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Stream<void> onAudioCompleted() => _player.onPlayerComplete;
}
