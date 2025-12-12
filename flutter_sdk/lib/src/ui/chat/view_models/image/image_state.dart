// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:equatable/equatable.dart';

enum ImageStatus { initial, errorPickingImage, errorCancellingPick }

final class ImageState extends Equatable {
  final ImageData? pickedImage;
  final ImageData? hiddenImagePick;
  final ImageStatus imageStatus;

  const ImageState({this.pickedImage, this.hiddenImagePick, this.imageStatus = ImageStatus.initial});

  ImageState copyWith({
    ImageData? Function()? pickedImage,
    ImageData? Function()? hiddenImagePick,
    ImageStatus? imageStatus,
  }) {
    return ImageState(
      pickedImage: pickedImage != null ? pickedImage() : this.pickedImage,
      hiddenImagePick: hiddenImagePick != null ? hiddenImagePick() : this.hiddenImagePick,
      imageStatus: imageStatus ?? this.imageStatus,
    );
  }

  @override
  List<Object?> get props => [pickedImage, imageStatus, hiddenImagePick];
}
