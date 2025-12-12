// Copyright (c) Yalochat, Inc. All rights reserved.
import 'dart:typed_data';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageData', () {
    test('creates instance with provided values', () {
      final bytes = Uint8List.fromList([1, 2, 3, 4]);
      final imageData = ImageData(
        path: '/path/to/image.jpg',
        bytes: bytes,
        mimeType: 'image/jpeg',
      );

      expect(imageData.path, equals('/path/to/image.jpg'));
      expect(imageData.bytes, equals(bytes));
      expect(imageData.mimeType, equals('image/jpeg'));
    });

    test('creates instance with null bytes defaults to empty', () {
      final imageData = ImageData(
        path: '/path/to/image.png',
        bytes: null,
        mimeType: 'image/png',
      );

      expect(imageData.path, equals('/path/to/image.png'));
      expect(imageData.bytes, equals(Uint8List.fromList([])));
      expect(imageData.mimeType, equals('image/png'));
    });

    test('copyWith returns new instance with updated values', () {
      final original = ImageData(
        path: '/original/path.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      final copied = original.copyWith(
        path: '/new/path.jpg',
        mimeType: 'image/png',
      );

      expect(copied.path, equals('/new/path.jpg'));
      expect(copied.bytes, equals(Uint8List.fromList([1, 2, 3])));
      expect(copied.mimeType, equals('image/png'));
      expect(original.path, equals('/original/path.jpg'));
    });

    test('copyWith with null values keeps original values', () {
      final original = ImageData(
        path: '/test/image.gif',
        bytes: Uint8List.fromList([5, 6, 7]),
        mimeType: 'image/gif',
      );

      final copied = original.copyWith();

      expect(copied.path, equals(original.path));
      expect(copied.bytes, equals(original.bytes));
      expect(copied.mimeType, equals(original.mimeType));
    });

    test('equality works correctly', () {
      final bytes = Uint8List.fromList([1, 2, 3]);

      final imageData1 = ImageData(
        path: '/test/image.jpg',
        bytes: bytes,
        mimeType: 'image/jpeg',
      );

      final imageData2 = ImageData(
        path: '/test/image.jpg',
        bytes: bytes,
        mimeType: 'image/jpeg',
      );

      final imageData3 = ImageData(
        path: '/different/image.jpg',
        bytes: bytes,
        mimeType: 'image/jpeg',
      );

      expect(imageData1, equals(imageData2));
      expect(imageData1, isNot(equals(imageData3)));
    });

    test('copyWith updates bytes correctly', () {
      final original = ImageData(
        path: '/test/image.jpg',
        bytes: Uint8List.fromList([1, 2, 3]),
        mimeType: 'image/jpeg',
      );

      final newBytes = Uint8List.fromList([4, 5, 6, 7]);
      final copied = original.copyWith(bytes: newBytes);

      expect(copied.bytes, equals(newBytes));
      expect(original.bytes, equals(Uint8List.fromList([1, 2, 3])));
    });
  });
}
