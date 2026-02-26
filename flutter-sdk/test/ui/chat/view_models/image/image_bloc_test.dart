// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  group(ImageBloc, () {
    late ImageRepository imageRepository;

    setUp(() {
      imageRepository = MockImageRepository();
    });

    group('image pick', () {
      blocTest<ImageBloc, ImageState>(
        'should pick an image from camera correctly',
        build: () => ImageBloc(imageRepository: imageRepository),
        act: (bloc) {
          when(
            () => imageRepository.pickImage(ImagePickSource.camera),
          ).thenAnswer(
            (_) async =>
                Result.ok(ImageData(path: 'test.png', mimeType: 'image/png')),
          );
          bloc.add(ImagePickFromCamera());
        },
        expect: () => [
          isA<ImageState>()
              .having(
                (s) => s.pickedImage,
                'picked image',
                equals(ImageData(path: 'test.png', mimeType: 'image/png')),
              )
              .having((s) => s.hiddenImagePick, 'hidden preview', null),
        ],
      );

      blocTest<ImageBloc, ImageState>(
        'should not emit anything if an image was already picked and the user does not pick a next image',
        build: () => ImageBloc(imageRepository: imageRepository),
        seed: () => ImageState(
          pickedImage: ImageData(path: 'test/test.png', mimeType: 'image/png'),
        ),
        act: (bloc) {
          when(
            () => imageRepository.pickImage(ImagePickSource.camera),
          ).thenAnswer((_) async => Result<ImageData?>.ok(null));
          bloc.add(ImagePickFromCamera());
        },
        expect: () => [],
      );

      blocTest<ImageBloc, ImageState>(
        'should pick an image from gallery correctly',
        build: () => ImageBloc(imageRepository: imageRepository),
        act: (bloc) {
          when(
            () => imageRepository.pickImage(ImagePickSource.gallery),
          ).thenAnswer(
            (_) async =>
                Result.ok(ImageData(path: 'test.png', mimeType: 'image/png')),
          );
          bloc.add(ImagePickFromGallery());
        },
        expect: () => [
          isA<ImageState>()
              .having(
                (s) => s.pickedImage,
                'picked image',
                equals(ImageData(path: 'test.png', mimeType: 'image/png')),
              )
              .having((s) => s.hiddenImagePick, 'hidden preview', null),
        ],
      );

      blocTest<ImageBloc, ImageState>(
        'should fail to pick an image when the picker repository fails',
        build: () => ImageBloc(imageRepository: imageRepository),
        act: (bloc) {
          when(
            () => imageRepository.pickImage(ImagePickSource.gallery),
          ).thenAnswer((_) async => Result.error(Exception('random error')));
          bloc.add(ImagePickFromGallery());
        },
        expect: () => [
          isA<ImageState>()
              .having((s) => s.pickedImage, 'picked image', equals(null))
              .having(
                (s) => s.imageStatus,
                'image status',
                equals(ImageStatus.errorPickingImage),
              ),
        ],
      );
    });

    group('image cancel pick', () {
      blocTest<ImageBloc, ImageState>(
        'should emit a null picked when the image pick successfully deleted the temporal file',
        build: () => ImageBloc(imageRepository: imageRepository),
        seed: () => ImageState(
          pickedImage: ImageData(path: 'test/test.png', mimeType: 'image/png'),
        ),
        act: (bloc) {
          when(
            () => imageRepository.deleteImage(bloc.state.pickedImage!),
          ).thenAnswer((_) async => Result.ok(Unit()));
          bloc.add(ImageCancelPick());
        },
        expect: () => [
          isA<ImageState>()
              .having((s) => s.pickedImage, 'picked image', equals(null))
              .having((s) => s.hiddenImagePick, 'hidden preview', null),
        ],
      );

      blocTest<ImageBloc, ImageState>(
        'should emit an error when the image pick fails to delete the temporal file',
        build: () => ImageBloc(imageRepository: imageRepository),
        seed: () => ImageState(
          pickedImage: ImageData(path: 'test/test.png', mimeType: 'image/png'),
        ),
        act: (bloc) {
          when(
            () => imageRepository.deleteImage(bloc.state.pickedImage!),
          ).thenAnswer((_) async => Result.error(Exception('test error')));
          bloc.add(ImageCancelPick());
        },
        expect: () => [
          isA<ImageState>().having(
            (s) => s.imageStatus,
            'image status',
            equals(ImageStatus.errorCancellingPick),
          ),
        ],
      );

      blocTest<ImageBloc, ImageState>(
        'should not emit anything if the picked image is null',
        build: () => ImageBloc(imageRepository: imageRepository),
        seed: () => ImageState(pickedImage: null),
        act: (bloc) {
          bloc.add(ImageCancelPick());
        },
        expect: () => [],
      );
    });

    group('image hide preview', () {
      blocTest<ImageBloc, ImageState>(
        'should hide an active image preview',
        build: () => ImageBloc(imageRepository: imageRepository),
        seed: () => ImageState(
          pickedImage: ImageData(path: 'test/test.png', mimeType: 'image/png'),
        ),
        act: (bloc) {
          bloc.add(ImageHidePreview());
        },
        expect: () => [
          isA<ImageState>()
              .having((s) => s.pickedImage, 'picked image', isNull)
              .having(
                (s) => s.hiddenImagePick,
                'hidden preview',
                equals(ImageData(path: 'test/test.png', mimeType: 'image/png')),
              ),
        ],
      );

      blocTest<ImageBloc, ImageState>(
        'should not emit anything if there is no preview to hide',
        build: () => ImageBloc(imageRepository: imageRepository),
        act: (bloc) {
          bloc.add(ImageHidePreview());
        },
        expect: () => [],
      );
    });

    group('image show preview', () {
      blocTest<ImageBloc, ImageState>(
        'should show a previously hidden preview',
        build: () => ImageBloc(imageRepository: imageRepository),
        seed: () => ImageState(
          pickedImage: null,
          hiddenImagePick: ImageData(
            path: 'test/test.png',
            mimeType: 'image/png',
          ),
        ),
        act: (bloc) {
          bloc.add(ImageShowPreview());
        },
        expect: () => [
          isA<ImageState>()
              .having(
                (s) => s.pickedImage,
                'picked image',
                equals(ImageData(path: 'test/test.png', mimeType: 'image/png')),
              )
              .having((s) => s.hiddenImagePick, 'hidden preview', isNull),
        ],
      );

      blocTest<ImageBloc, ImageState>(
        'should not emit anything if there was no hidden preview',
        build: () => ImageBloc(imageRepository: imageRepository),
        act: (bloc) => bloc.add(ImageShowPreview()),
        expect: () => [],
      );
    });
  });
}
