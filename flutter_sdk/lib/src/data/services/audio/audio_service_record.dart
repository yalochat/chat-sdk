// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/exceptions/permission_exception.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:record/record.dart';

import 'audio_service.dart';

class AudioServiceRecord implements AudioService {
  final AudioRecorder _recorder;

  AudioServiceRecord([
    AudioRecorder? recorder,

  ]) : _recorder = recorder ?? AudioRecorder();

  @override
  Future<Result<Unit>> record(String path, AudioEncoding encoding) async {
    if (!(await _recorder.hasPermission())) {
      Result.error(PermissionException('recording'));
    }
    final encoder = switch (encoding) {
      AudioEncoding.wav => AudioEncoder.wav,
    };
    try {
      await _recorder.start(
        RecordConfig(encoder: encoder),
        path: path,
      );
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> stop() async {
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
  }
}
