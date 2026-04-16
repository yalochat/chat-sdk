// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ButtonsMessage extends StatelessWidget {
  final ChatMessage message;

  const ButtonsMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ChatThemeCubit>().chatTheme;
    final messagesBloc = context.read<MessagesBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.header != null && message.header!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              bottom: SdkConstants.columnItemSpace / 2,
            ),
            child: Text(message.header!, style: theme.messageHeaderStyle),
          ),
        if (message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(
              bottom: SdkConstants.columnItemSpace / 2,
            ),
            child: Text(
              message.content,
              style: theme.assistantMessageTextStyle,
            ),
          ),
        if (message.footer != null && message.footer!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: SdkConstants.columnItemSpace),
            child: Text(message.footer!, style: theme.messageFooterStyle),
          ),
        ...message.buttons.map(
          (label) => Padding(
            padding: const EdgeInsets.only(top: SdkConstants.columnItemSpace),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: theme.buttonsMessageButtonColor,
                foregroundColor: theme.buttonsMessageButtonForegroundColor,
                side: BorderSide(color: theme.buttonsMessageButtonBorderColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    SdkConstants.messageBorderRadius / 2,
                  ),
                ),
              ),
              onPressed: () =>
                  messagesBloc.add(ChatSendTextMessage(text: label)),
              child: Text(label, style: theme.buttonsMessageButtonTextStyle),
            ),
          ),
        ),
      ],
    );
  }
}
