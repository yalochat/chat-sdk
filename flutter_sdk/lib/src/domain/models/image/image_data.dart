// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ImageData extends Equatable {
  final String path;
  final Uint8List bytes;

  ImageData({String? path, Uint8List? bytes})
    : path = path ?? '',
      bytes = bytes ?? Uint8List.fromList([]);

  ImageData copyWith({String? path, Uint8List? bytes}) {
    return ImageData(path: path ?? this.path, bytes: bytes ?? this.bytes);
  }

  @override
  List<Object?> get props => [path, bytes];
}
