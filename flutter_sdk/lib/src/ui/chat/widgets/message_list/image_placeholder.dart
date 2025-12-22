// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              color: chatThemeCubit.state.imagePlaceholderBackgroundColor,
            ),
            Icon(
              chatThemeCubit.state.imagePlaceHolderIcon,
              color: chatThemeCubit.state.imagePlaceholderIconColor,
              size: SdkConstants.imagePlaceHolderIconSize,
            ),
          ],
        );
      },
    );
  }
}
