// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageEvent', () {
    group(ImagePickFromCamera, () {

      test('should support equality comparison', () {
        final event1 = ImagePickFromCamera();
        final event2 = ImagePickFromCamera();
        expect(event1, equals(event2));
      });
    });

    group(ImagePickFromGallery, () {

      test('should support equality comparison', () {
        final event1 = ImagePickFromGallery();
        final event2 = ImagePickFromGallery();
        expect(event1, equals(event2));
      });
    });

    group(ImageCancelPick, () {

      test('should support equality comparison', () {
        final event1 = ImageCancelPick();
        final event2 = ImageCancelPick();
        expect(event1, equals(event2));
      });
    });

    group(ImageHidePreview, () {

      test('should support equality comparison', () {
        final event1 = ImageHidePreview();
        final event2 = ImageHidePreview();
        expect(event1, equals(event2));
      });
    });

    group(ImageShowPreview, () {
      test('should support equality comparison', () {
        final event1 = ImageShowPreview();
        final event2 = ImageShowPreview();
        expect(event1, equals(event2));
      });
    });

    test('different events should not be equal', () {
      final cameraEvent = ImagePickFromCamera();
      final galleryEvent = ImagePickFromGallery();
      final cancelEvent = ImageCancelPick();

      expect(cameraEvent, isNot(equals(galleryEvent)));
      expect(cameraEvent, isNot(equals(cancelEvent)));
      expect(galleryEvent, isNot(equals(cancelEvent)));
    });
  });
}
