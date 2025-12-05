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
          Result.ok(
            ImageData(
              path: 'test/test.png',
              bytes: Uint8List.fromList([2, 3, 4]),
            ),
          ),
        );
      });

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
          expect(result, Result<ImageData?>.error(FormatException("mime type not supported, received 'application/json'")));
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

    group('delete image', () {
      test('should delete the image file', () async {
        when(
          () => cameraService.deleteImage('test-path'),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await imageRepository.deleteImage('test-path');
        expect(result, Result.ok(Unit()));
      });
      test(
        'should return an error when it fails to pick an image with the camera service',
        () async {
          final error = Exception('test error');
          when(
            () => cameraService.deleteImage('test-path'),
          ).thenAnswer((_) async => Result<Unit>.error(error));

          final result = await imageRepository.deleteImage('test-path');
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
