// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AssistantMessage extends StatelessWidget {
  final ChatMessage message;
  const AssistantMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    assert(
      message.role == MessageRole.assistant,
      'AssistantMessages can only render messages with role assistant',
    );
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return Flexible(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            padding: EdgeInsets.all(SdkConstants.messagePadding),
            child: switch (message.type) {
              MessageType.text => SelectableText(
                message.content,
                style: chatThemeCubit.chatTheme.assistantMessageTextStyle,
                textAlign: TextAlign.left,
              ),
              _ => throw UnimplementedError('Unimplemented assistant message type ${message.type}'),
            },
          );
        },
      ),
    );
  }
}
