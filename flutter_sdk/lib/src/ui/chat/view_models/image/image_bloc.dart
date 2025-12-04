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
    on<ImagePick>(_handleImagePick);
    on<ImageRemove>(_handleImageRemove);
  }

  Future<void> _handleImagePick(
    ImagePick event,
    Emitter<ImageState> emit,
  ) async {
    final result = await _imageRepository.pickImage();
    switch (result) {
      case Ok():
        log.info('Image picked successfully with file name ${result.result}');
        emit(state.copyWith(pickedImage: result.result));
        break;
      case Error():
        break;
    }
  }

  Future<void> _handleImageRemove(
    ImageRemove event,
    Emitter<ImageState> emit,
  ) async {
    emit(state.copyWith(pickedImage: ''));
  }
}
