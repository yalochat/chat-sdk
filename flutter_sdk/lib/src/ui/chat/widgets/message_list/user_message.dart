// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/user_voice_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'user_image_message.dart';

class UserMessage extends StatelessWidget {
  final ChatMessage message;
  const UserMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    assert(
      message.role == MessageRole.user,
      'UserMessage can only render messages with role user',
    );
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            padding: EdgeInsets.all(SdkConstants.messagePadding),
            decoration: BoxDecoration(
              color: chatThemeCubit.chatTheme.userMessageColor,
              borderRadius: BorderRadius.circular(
                SdkConstants.messageBorderRadius,
              ),
            ),
            child: switch (message.type) {
              MessageType.text => SelectableText(
                message.content,
                style: chatThemeCubit.chatTheme.userMessageTextStyle,
              ),
              MessageType.voice => UserVoiceMessage(message: message),
              MessageType.image => UserImageMessage(message: message),
            },
          );
        },
      ),
    );
  }
}
