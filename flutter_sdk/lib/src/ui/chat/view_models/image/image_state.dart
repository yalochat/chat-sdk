// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

final class ImageState extends Equatable {
  final String pickedImage;

  const ImageState({this.pickedImage = ''});

  ImageState copyWith({String? pickedImage}) {
    return ImageState(pickedImage: pickedImage ?? this.pickedImage);
  }

  @override
  List<Object?> get props => [pickedImage];
}
