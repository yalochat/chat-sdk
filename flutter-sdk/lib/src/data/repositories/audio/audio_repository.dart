// Copyright (c) Yalochat, Inc. All rights reserved.

// Repository that it is in charge of recording audio

import 'package:chat_flutter_sdk/src/common/result.dart';

abstract class AudioRepository {
  Future<Result<String>> recordAudio();

  Stream<double> getAmplitudes(Duration duration);

  Future<Result<Unit>> playAudio(String path);

  Future<Result<Unit>> pauseAudio();

  Stream<void> onAudioCompleted();

  Future<Result<Unit>> stopRecording();
}
