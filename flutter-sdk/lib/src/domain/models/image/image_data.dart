// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class ImageData extends Equatable {
  final String path;
  final Uint8List bytes;
  final String mimeType;

  ImageData({required this.path, Uint8List? bytes, required this.mimeType})
    : bytes = bytes ?? Uint8List.fromList([]);

  ImageData copyWith({
    String? path,
    Uint8List? bytes,
    String? mimeType,
  }) {
    return ImageData(
      path: path ?? this.path,
      bytes: bytes ?? this.bytes,
      mimeType: mimeType ?? this.mimeType,
    );
  }

  @override
  List<Object?> get props => [path, bytes, mimeType];
}
