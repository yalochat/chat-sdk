// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service_file.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  group(CameraServiceFile, () {
    late ImagePicker picker;
    late CameraService cameraService;
    late XFile mockXFile;
    setUp(() {
      picker = MockImagePicker();
      cameraService = CameraServiceFile(picker: picker);
      mockXFile = MockXFile();
    });

    group('pick image', () {
      test(
        'pick image from camera and save it to file correctly, must return file extension',
        () async {
          when(
            () => picker.pickImage(source: ImageSource.camera),
          ).thenAnswer((_) async => mockXFile);
          when(() => mockXFile.path).thenReturn('test-path.png');
          when(
            () => mockXFile.saveTo('test/mock-name.png'),
          ).thenAnswer((_) async => ());

          final result = await cameraService.pickImage(
            ImageSource.camera,
          );

          expect(result, equals(Result.ok('test/mock-name.png')));
        },
      );
      test(
        'returns an error when the user does not pick any image',
        () async {
          when(
            () => picker.pickImage(source: ImageSource.camera),
          ).thenAnswer((_) async => mockXFile);
          when(() => mockXFile.path).thenReturn('test-path.png');
          when(
            () => mockXFile.saveTo('test/mock-name.png'),
          ).thenAnswer((_) async => ());

          final result = await cameraService.pickImage(
            'test/mock-name',
            ImageSource.camera,
          );

          expect(result, equals(Result.ok('test/mock-name.png')));
        },
      );
    });
  });
}
