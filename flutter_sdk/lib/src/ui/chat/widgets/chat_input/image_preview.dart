// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;

  const ImagePreview({super.key, required this.imagePath});
  @override
  Widget build(BuildContext context) {
    File imageFile = File(imagePath);

    final chatTheme = context.watch<ChatThemeCubit>();
    final imageBloc = context.read<ImageBloc>();
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    return Container(
      padding: EdgeInsets.only(
        top: SdkConstants.rowItemSpace,
        bottom: SdkConstants.rowItemSpace,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(
              SdkConstants.imagePreviewBorderRadius,
            ),
            child: Image.file(
              imageFile,
              fit: BoxFit.cover,
              width: orientation == Orientation.portrait
                  ? size.width * 0.17
                  : size.width * 0.1,
              height: orientation == Orientation.portrait
                  ? size.height * 0.14
                  : size.height * 0.3,
            ),
          ),

          IconButton(
            icon: chatTheme.state.trashIcon,
            iconSize: SdkConstants.imagePreviewIconSize,
            onPressed: () {
              imageBloc.add(ImageCancelPick());
            },
          ),
        ],
      ),
    );
  }
}
