// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/user_audio_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMessage extends StatelessWidget {
  final ChatMessage message;
  const UserMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
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
            MessageType.voice => UserAudioMessage(message: message),
            _ => Container(),
          },
        ),
        SizedBox(width: SdkConstants.rowItemSpace),
      ],
    );
  }
}
