// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';

abstract class ImageRepository {

  Future<Result<String>> pickImage();
}
