// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:typed_data';

import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:image_picker/image_picker.dart';

abstract class YaloMediaService {
  Future<Result<MediaUploadResponse>> uploadMedia(XFile file);
  Future<Result<Uint8List>> downloadMedia(String url);
}
