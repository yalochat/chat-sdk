// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

sealed class ImageEvent {}

final class ImagePickFromCamera extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ImagePickFromGallery extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ImageCancelPick extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ImageHidePreview extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ImageShowPreview extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
