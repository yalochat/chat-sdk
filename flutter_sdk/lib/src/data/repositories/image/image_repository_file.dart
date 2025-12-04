// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import 'image_repository.dart';

class ImageRepositoryFile implements ImageRepository {
  final CameraService _cameraService;
  final Future<Directory> Function() _directory;
  final Logger log = Logger('ImageRepositoryFile');

  ImageRepositoryFile(
    CameraService cameraService,
    Future<Directory> Function() directory,
  ) : _cameraService = cameraService,
      _directory = directory;

  @override
  Future<Result<String>> pickImage() async {
    log.info('Picking file with camera');
    final directory = await _directory();

    var uuid = Uuid();
    var imageName = uuid.v4();
    var fileName = '${directory.path}/$imageName';
    log.info('Trying to pick image with file name: $fileName');
    var result = await _cameraService.pickImage(fileName);

    return switch (result) {
      Ok() => Result.ok(result.result),
      Error() => Result.error(result.error),
    };
  }
}
