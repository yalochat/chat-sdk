// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';

enum ImagePickSource { gallery, camera }

abstract class ImageRepository {
  Future<Result<ImageData?>> pickImage(ImagePickSource source);

  Future<Result<ImageData>> saveImage(ImageData imageData);

  Future<Result<Unit>> deleteImage(ImageData imageData);
}
