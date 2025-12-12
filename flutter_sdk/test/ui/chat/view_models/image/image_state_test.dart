// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_state.dart';
import 'package:test/test.dart';

void main() {
  group(ImageState, () {
    test('creates instance with default values', () {
      final imageState = ImageState();

      expect(imageState.pickedImage, isNull);
      expect(imageState.imageStatus, equals(ImageStatus.initial));
    });

    test('creates instance with provided image', () {
      final imageData = ImageData(
        path: '/test/image.jpg',
        bytes: null,
        mimeType: 'image/jpeg',
      );
      final imageState = ImageState(pickedImage: imageData);

      expect(imageState.pickedImage, equals(imageData));
    });

    test('copyWith returns new instance with updated image', () {
      final originalImage = ImageData(
        path: '/original/image.jpg',
        bytes: null,
        mimeType: 'image/jpeg',
      );
      final newImage = ImageData(
        path: '/new/image.png',
        bytes: null,
        mimeType: 'image/png',
      );
      final original = ImageState(pickedImage: originalImage);

      final copied = original.copyWith(pickedImage: () => newImage);

      expect(copied.pickedImage, equals(newImage));
      expect(original.pickedImage, equals(originalImage));
    });

    test('copyWith without parameters keeps original values', () {
      final imageData = ImageData(
        path: '/test/image.jpg',
        bytes: null,
        mimeType: 'image/jpeg',
      );
      final original = ImageState(pickedImage: imageData);

      final copied = original.copyWith();

      expect(copied.pickedImage, equals(original.pickedImage));
    });

    test('copyWith can set image and preview to null', () {
      final imageData = ImageData(
        path: '/test/image.jpg',
        bytes: null,
        mimeType: 'image/jpeg',
      );
      final original = ImageState(
        pickedImage: imageData,
        hiddenImagePick: imageData,
      );

      final copied = original.copyWith(
        pickedImage: () => null,
        hiddenImagePick: () => null,
      );

      expect(copied.pickedImage, isNull);
      expect(copied.hiddenImagePick, isNull);
      expect(original.pickedImage, equals(imageData));
    });

    test('equality works correctly', () {
      final imageData = ImageData(
        path: '/test/image.jpg',
        bytes: null,
        mimeType: 'image/jpeg',
      );

      final imageState1 = ImageState(pickedImage: imageData);
      final imageState2 = ImageState(pickedImage: imageData);
      final imageState3 = ImageState();

      expect(imageState1, equals(imageState2));
      expect(imageState1, isNot(equals(imageState3)));
    });
  });
}
