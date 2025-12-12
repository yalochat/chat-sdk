// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final ImageRepository _imageRepository;
  final Logger log = Logger('ImageViewModel');
  ImageBloc({required ImageRepository imageRepository})
    : _imageRepository = imageRepository,
      super(ImageState()) {
    on<ImagePickFromCamera>(_handleImagePickCamera);
    on<ImagePickFromGallery>(_handleImagePickGallery);
    on<ImageCancelPick>(_handleImageCancelPick);
    on<ImageHidePreview>(_handleImageHidePreview);
    on<ImageShowPreview>(_handleImageShowPreview);
  }

  Future<void> _handleImagePick(
    ImagePickSource source,
    Emitter<ImageState> emit,
  ) async {
    final result = await _imageRepository.pickImage(source);
    switch (result) {
      case Ok():
        log.info(
          'Image picked successfully with file name ${result.result?.path}',
        );
        if (result.result != null) {
          emit(state.copyWith(pickedImage: () => result.result));
        }
        break;
      case Error():
        log.severe('Unable to pick user image', result.error);
        emit(state.copyWith(imageStatus: ImageStatus.errorPickingImage));
        break;
    }
  }

  Future<void> _handleImagePickCamera(
    ImagePickFromCamera event,
    Emitter<ImageState> emit,
  ) => _handleImagePick(ImagePickSource.camera, emit);

  Future<void> _handleImagePickGallery(
    ImagePickFromGallery event,
    Emitter<ImageState> emit,
  ) => _handleImagePick(ImagePickSource.gallery, emit);

  Future<void> _handleImageCancelPick(
    ImageCancelPick event,
    Emitter<ImageState> emit,
  ) async {
    log.info('Cancelling pick image');
    if (state.pickedImage == null) {
      log.info('No image to cancel pick');
      return;
    }

    final result = await _imageRepository.deleteImage(state.pickedImage!);
    switch (result) {
      case Ok():
        log.info('Image pick was cancelled successfully');
        emit(
          state.copyWith(pickedImage: () => null, hiddenImagePick: () => null),
        );
        break;
      case Error():
        log.severe('Unable to cancel image pick', result.error);
        emit(state.copyWith(imageStatus: ImageStatus.errorCancellingPick));
        break;
    }
  }

  Future<void> _handleImageHidePreview(
    ImageHidePreview event,
    Emitter<ImageState> emit,
  ) async {
    if (state.pickedImage == null) {
      log.info('No image preview to hide');
      return;
    }
    log.info('Hiding preview');
    emit(
      state.copyWith(
        pickedImage: () => null,
        hiddenImagePick: () => state.pickedImage,
      ),
    );
  }

  Future<void> _handleImageShowPreview(
    ImageShowPreview event,
    Emitter<ImageState> emit,
  ) async {
    if (state.hiddenImagePick == null) {
      log.info('No image preview to restore');
      return;
    }
    log.info('Showing hidden preview');
    emit(
      state.copyWith(
        pickedImage: () => state.hiddenImagePick,
        hiddenImagePick: () => null,
      ),
    );
  }
}
