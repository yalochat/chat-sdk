// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'image_repository.dart';

class ImageRepositoryFile implements ImageRepository {
  final CameraService _cameraService;
  final Future<Directory> Function() _directory;
  final Uuid _uuid;
  final Logger log = Logger('ImageRepositoryFile');

  ImageRepositoryFile(
    CameraService cameraService,
    Future<Directory> Function() directory, [
    Uuid? uuid,
  ]) : _cameraService = cameraService,
       _directory = directory,
       _uuid = uuid ?? Uuid();

  @override
  Future<Result<ImageData?>> pickImage(ImagePickSource source) async {
    log.info('Picking file with source: $source');

    final imageSource = switch (source) {
      ImagePickSource.gallery => ImageSource.gallery,
      ImagePickSource.camera => ImageSource.camera,
    };

    final result = await _cameraService.pickImage(imageSource);

    switch (result) {
      case Ok():
        log.info('Image picked successfully');
        if (result.result == null) {
          log.fine('User did not select an image');
          return Result.ok(null);
        }

        final mimeType = result.result!.mimeType;
        if (mimeType != 'image/jpeg' || mimeType != 'image/png') {
          return Result.error(
            FormatException("mime type not supported, received '$mimeType'"),
          );
        }

        return Result.ok(
          ImageData(
            path: result.result!.path,
            bytes: await result.result!.readAsBytes(),
          ),
        );
      case Error():
        log.severe('Unable to pick image', result.error);
        return Result.error(result.error);
    }
  }

  @override
  Future<Result<Unit>> deleteImage(String path) =>
      _cameraService.deleteImage(path);
}
