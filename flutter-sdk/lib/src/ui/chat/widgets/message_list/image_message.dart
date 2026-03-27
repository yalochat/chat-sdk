// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart'
    show ChatThemeCubit;
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ImageMessage extends StatelessWidget {
  final ChatMessage message;

  const ImageMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    assert(
      message.type == MessageType.image && message.fileName != null,
      'ImageMessage is only able to render image messages with non-empty fileName',
    );
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final textStyle = message.role == MessageRole.user
        ? chatThemeCubit.chatTheme.userMessageTextStyle
        : chatThemeCubit.chatTheme.assistantMessageTextStyle;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SdkConstants.messageBorderRadius),
            child: FittedBox(
              fit: BoxFit.cover,
              child: Image.file(File(message.fileName!)),
            ),
          ),
        ),
        SizedBox(height: SdkConstants.columnItemSpace),
        if (message.content.isNotEmpty)
          SelectableText(
            message.content,
            style: textStyle,
          ),
      ],
    );
  }
}
