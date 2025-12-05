// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

abstract class CameraService {
  Future<Result<XFile?>> pickImage(ImageSource source);
  Future<Result<Unit>> saveImage(String path);
  Future<Result<Unit>> deleteImage(String path);
}
