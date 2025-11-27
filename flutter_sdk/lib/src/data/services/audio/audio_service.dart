// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';

enum AudioEncoding { wav }

// Service that provides audio managing functions, from recording to playing audio
abstract class AudioService {
  Future<Result<Unit>> record(String path, AudioEncoding encoding);

  Future<Result<Unit>> stopRecord();

  Stream<double> getAmplitudeStream(Duration duration);

  Future<Result<Unit>> playAudio(String path);

  Future<Result<Unit>> pauseAudio();

  Future<void> dispose();
}
