// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';

abstract class CameraService {

  Future<Result<String>> pickImage(String prefix);
}



