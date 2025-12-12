// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';
import 'dart:typed_data';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository_file.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

class MockCameraService extends Mock implements CameraService {}

class MockUuid extends Mock implements Uuid {}

class MockXFile extends Mock implements XFile {}

void main() {
  group(ImageRepositoryFile, () {
    late Uuid uuid;
    late CameraService cameraService;
    late ImageRepository imageRepository;
    late XFile xFile;

    setUp(() {
      uuid = MockUuid();
      cameraService = MockCameraService();
      imageRepository = ImageRepositoryFile(
        cameraService,
        () async => Directory('test'),
        uuid,
      );
      xFile = MockXFile();
      when(() => uuid.v4()).thenReturn('test-uuid');
      when(() => xFile.path).thenReturn('test/test.png');
      when(() => xFile.mimeType).thenReturn('image/png');
    });

    setUpAll(() {
      registerFallbackValue(XFile('test-path'));
    });

    group('pick image', () {
      test('should pick an image with the camera service', () async {
        when(
          () => cameraService.pickImage(ImageSource.camera),
        ).thenAnswer((_) async => Result.ok(xFile));

        when(
          () => xFile.readAsBytes(),
        ).thenAnswer((_) async => Uint8List.fromList([2, 3, 4]));

        final result = await imageRepository.pickImage(ImagePickSource.camera);
        expect(
          result,
          Result<ImageData?>.ok(
            ImageData(
              path: 'test/test.png',
              bytes: Uint8List.fromList([2, 3, 4]),
              mimeType: 'image/png',
            ),
          ),
        );
      });

      test(
        'should return a null value when the user does not select an image',
        () async {
          when(
            () => cameraService.pickImage(ImageSource.camera),
          ).thenAnswer((_) async => Result.ok(null));

          final result = await imageRepository.pickImage(
            ImagePickSource.camera,
          );
          expect(result, Result<ImageData?>.ok(null));
        },
      );

      test(
        'should return an error when the mime type is unsupported',
        () async {
          when(
            () => cameraService.pickImage(ImageSource.camera),
          ).thenAnswer((_) async => Result.ok(xFile));

          when(
            () => xFile.readAsBytes(),
          ).thenAnswer((_) async => Uint8List.fromList([2, 3, 4]));

          when(() => xFile.mimeType).thenReturn('application/json');

          final result = await imageRepository.pickImage(
            ImagePickSource.camera,
          );
          expect(
            result,
            isA<Error<ImageData?>>().having(
              (s) => s.error,
              'error',
              isA<FormatException>(),
            ),
          );
        },
      );

      test(
        'should return an error when it fails to pick an image with the camera service',
        () async {
          final testError = Exception('test error');
          when(
            () => cameraService.pickImage(ImageSource.camera),
          ).thenAnswer((_) async => Result.error(testError));

          final result = await imageRepository.pickImage(
            ImagePickSource.camera,
          );
          expect(result, Result<ImageData?>.error(testError));
        },
      );
    });

    group('save image', () {
      test(
        'should save the file correctly when the image data is valid',
        () async {
          ImageData stubImageData = ImageData(
            path: 'test.png',
            mimeType: 'image/png',
          );

          when(
            () => cameraService.saveImage('test/test-uuid.png', any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await imageRepository.saveImage(stubImageData);
          expect(
            result,
            equals(
              Result.ok(
                ImageData(path: 'test/test-uuid.png', mimeType: 'image/png'),
              ),
            ),
          );
        },
      );

      test('should return an error when saving the image fails', () async {
        ImageData stubImageData = ImageData(
          path: 'test.png',
          mimeType: 'image/png',
        );

        when(
          () => cameraService.saveImage('test/test-uuid.png', any()),
        ).thenAnswer((_) async => Result.error(Exception('test error')));

        final result = await imageRepository.saveImage(stubImageData);
        expect(
          result,
          isA<Error<ImageData>>().having(
            (s) => s.error,
            'error',
            isA<Exception>(),
          ),
        );
      });

      test('should return an error when the mime type is not valid', () async {
        ImageData stubImageData = ImageData(path: 'test.png', mimeType: '');

        final result = await imageRepository.saveImage(stubImageData);
        expect(
          result,
          isA<Error<ImageData>>().having(
            (s) => s.error,
            'error',
            isA<FormatException>(),
          ),
        );
      });

      test('should return an error when the path is not valid', () async {
        ImageData stubImageData = ImageData(
          path: 'test',
          mimeType: 'image/png',
        );

        final result = await imageRepository.saveImage(stubImageData);
        expect(
          result,
          isA<Error<ImageData>>().having(
            (s) => s.error,
            'error',
            isA<FormatException>(),
          ),
        );
      });
    });

    group('delete image', () {
      test('should delete the image file', () async {
        ImageData stubImageData = ImageData(
          path: 'test.png',
          mimeType: 'image/png',
        );
        when(
          () => cameraService.deleteImage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await imageRepository.deleteImage(stubImageData);
        expect(result, Result.ok(Unit()));
      });

      test(
        'should return an error when it fails to pick an image with the camera service',
        () async {
          ImageData stubImageData = ImageData(
            path: 'test.png',
            mimeType: 'image/png',
          );
          final error = Exception('test error');
          when(
            () => cameraService.deleteImage(any()),
          ).thenAnswer((_) async => Result<Unit>.error(error));

          final result = await imageRepository.deleteImage(stubImageData);
          expect(result, Result<Unit>.error(error));
        },
      );
    });

    test('should create a default repository when no uuid is provided', () {
      final repo = ImageRepositoryFile(
        cameraService,
        () async => Directory('test'),
      );
      expect(repo, isA<ImageRepository>());
    });
  });
}
