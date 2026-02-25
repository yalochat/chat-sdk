// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';

import 'camera_service.dart';

class CameraServiceFile implements CameraService {
  final Logger log = Logger('CameraService');
  final ImagePicker _picker;

  CameraServiceFile({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  @override
  Future<Result<XFile?>> pickImage(ImageSource source) async {
    log.info('Trying to pick image');
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        imageQuality: SdkConstants.imageQuality,
      );

      if (photo == null) {
        log.info("User didn't pick an image");
        return Result.ok(null);
      }

      final mimeType = lookupMimeType(photo.path);
      log.info('User picked an image successfully, MIME type "$mimeType"');
      return Result.ok(XFile(photo.path, mimeType: mimeType));
    } on Exception catch (e) {
      log.severe('Unable to pick image', e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> saveImage(String path, XFile file) async {
    log.info('Saving image to path: $path');
    try {
      await file.saveTo(path);
      log.info('Image was saved correctly');
      return Result.ok(Unit());
    } on Exception catch (e) {
      log.severe('Unable to save image to path', e);
      return Result.error(e);
    }
  }

  @override
  Future<Result<Unit>> deleteImage(
    XFile file, [
    @visibleForTesting bool isWeb = false,
  ]) async {
    log.info('Deleting image path ${file.path}');
    if (kIsWeb || isWeb) {
      log.warning('Web environment does not store files on disk, returning ok');
      return Result.ok(Unit());
    }
    try {
      final diskFile = File(file.path);
      await diskFile.delete();
      log.info('Image deleted successfully');
      return Result.ok(Unit());
    } on Exception catch (e) {
      log.severe('Unable to delete image', e);
      return Result.error(e);
    }
  }
}
