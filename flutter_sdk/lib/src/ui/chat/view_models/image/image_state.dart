// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:equatable/equatable.dart';

final class ImageState extends Equatable {
  final ImageData? pickedImage;

  const ImageState({this.pickedImage});

  ImageState copyWith({ImageData? Function()? pickedImage}) {
    return ImageState(
      pickedImage: pickedImage != null ? pickedImage() : this.pickedImage,
    );
  }

  @override
  List<Object?> get props => [pickedImage];
}
