// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service_file.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  group(CameraServiceFile, () {
    late ImagePicker picker;
    late CameraServiceFile cameraService;
    late XFile mockXFile;
    setUp(() {
      picker = MockImagePicker();
      cameraService = CameraServiceFile(picker: picker);
      mockXFile = MockXFile();
    });

    group('pick image', () {
      test(
        'should pick image from camera and save it to file correctly, must return file extension',
        () async {
          when(
            () => picker.pickImage(
              source: ImageSource.camera,
              imageQuality: SdkConstants.imageQuality,
            ),
          ).thenAnswer((_) async => mockXFile);

          when(() => mockXFile.path).thenReturn('test.png');

          final result = await cameraService.pickImage(ImageSource.camera);

          expect(
            result,
            isA<Ok<XFile?>>()
                .having((s) => s.result!.mimeType, 'file', equals('image/png'))
                .having((s) => s.result!.path, 'path', 'test.png'),
          );
        },
      );
      test(
        'should return a null ok result when the user does not pick any image',
        () async {
          when(
            () => picker.pickImage(
              source: ImageSource.camera,
              imageQuality: SdkConstants.imageQuality,
            ),
          ).thenAnswer((_) async => null);

          final result = await cameraService.pickImage(ImageSource.camera);

          expect(result, equals(Result<XFile?>.ok(null)));
        },
      );

      test('should return an error when the image picker fails', () async {
        final testError = Exception('test exception');
        when(
          () => picker.pickImage(
            source: ImageSource.camera,
            imageQuality: SdkConstants.imageQuality,
          ),
        ).thenThrow(testError);

        final result = await cameraService.pickImage(ImageSource.camera);

        expect(result, equals(Result<XFile?>.error(testError)));
      });
    });

    group('save image', () {
      test('should save an image to the path sent successfully', () async {
        when(
          () => mockXFile.saveTo('test/test-path.png'),
        ).thenAnswer((_) async => ());

        final result = await cameraService.saveImage(
          'test/test-path.png',
          mockXFile,
        );
        expect(result, equals(Result<Unit>.ok(Unit())));
      });

      test('should fail to save an image when saving fails', () async {
        final testError = Exception('test error');
        when(() => mockXFile.saveTo('test/test-path.png')).thenThrow(testError);

        final result = await cameraService.saveImage(
          'test/test-path.png',
          mockXFile,
        );
        expect(result, equals(Result<Unit>.error(testError)));
      });
    });

    group('delete image', () {
      String testFilePath = 'test_file.txt';
      late File file;
      setUp(() {
        file = File(testFilePath);
        file.writeAsStringSync('Test content');
      });

      tearDown(() async {
        if (await file.exists()) {
          await file.delete();
        }
      });

      test('should delete an image successfully', () async {
        when(() => mockXFile.path).thenReturn(testFilePath);
        final result = await cameraService.deleteImage(mockXFile);
        expect(result, equals(Result<Unit>.ok(Unit())));
        await expectLater(file.exists(), completion(false));
      });

      test('should fail to save an image when saving fails', () async {
        when(() => mockXFile.path).thenReturn('no-file-that-exists-here.png');
        final result = await cameraService.deleteImage(mockXFile);

        expect(result, isA<Error<Unit>>());
      });

      test('should return ok when the environment is web', () async {
        when(() => mockXFile.path).thenReturn('test/test.jpeg');
        final result = await cameraService.deleteImage(mockXFile, true);

        expect(result, isA<Ok<Unit>>());
      });
    }, tags: ['integration']);
  });
}
