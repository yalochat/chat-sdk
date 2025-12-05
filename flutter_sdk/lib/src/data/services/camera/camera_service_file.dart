// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:image_picker/image_picker.dart';

import 'camera_service.dart';

class CameraServiceFile implements CameraService {
  final ImagePicker _picker;

  CameraServiceFile({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  @override
  Future<Result<XFile?>> pickImage(ImageSource source) async {
    final XFile? photo = await _picker.pickImage(source: source, imageQuality: 90);
    if (photo == null) {
      return Result.ok(photo);
    }
    try {
      return Result.ok(photo);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> deleteImage(String path) {
    throw UnimplementedError();
  }

  @override
  Future<Result<Unit>> saveImage(String path, XFile file) async {
    try {
      await file.saveTo(path);
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
