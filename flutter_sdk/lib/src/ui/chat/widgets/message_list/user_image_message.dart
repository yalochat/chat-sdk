// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart'
    show ChatThemeCubit;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserImageMessage extends StatelessWidget {
  final ChatMessage message;

  const UserImageMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    assert(
      message.type == MessageType.image && message.fileName != null,
      'UserImageMessage is only able to render image messages without empty fileName',
    );
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    File imageFile = File(message.fileName!);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.file(imageFile)
          ),
        ),
        if (message.content.isNotEmpty)
        SelectableText(
          message.content,
          style: chatThemeCubit.chatTheme.userMessageTextStyle,
        ),
      ],
    );
  }
}
