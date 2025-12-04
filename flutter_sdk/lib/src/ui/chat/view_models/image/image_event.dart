// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

sealed class ImageEvent {}

final class ImagePick extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ImageRemove extends ImageEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
