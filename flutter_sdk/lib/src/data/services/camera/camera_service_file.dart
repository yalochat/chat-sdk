// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import 'camera_service.dart';

class CameraServiceFile implements CameraService {
  final ImagePicker _picker;

  CameraServiceFile({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  @override
  Future<Result<String>> pickImage(String prefix) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      return Result.error(Exception('User cancelled image'));
    }

    final fileExtension = extension(photo.path);
    try {
      final fileName = '$prefix$fileExtension';
      await photo.saveTo(fileName);
      return Result.ok(fileName);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
