// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/assistant_product_message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

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
            constraints: BoxConstraints(maxWidth: constraints.maxWidth),
            padding: EdgeInsets.all(SdkConstants.messagePadding),
            child: switch (message.type) {
              MessageType.text => Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth * 0.9,
                ),
                child: Markdown(
                  data: message.content,
                  shrinkWrap: true,
                  styleSheet: MarkdownStyleSheet(
                    textAlign: WrapAlignment.start,
                    p: chatThemeCubit.chatTheme.assistantMessageTextStyle,
                  ),
                ),
              ),
              MessageType.product => AssistantProductMessage(
                message: message,
                direction: Axis.vertical,
              ),
              MessageType.productCarousel => AssistantProductMessage(
                message: message,
                direction: Axis.horizontal,
              ),
              // FIXME: Instead of throwing a special message could be rendered
              _ => throw UnimplementedError(
                'Unimplemented assistant message type ${message.type}',
              ),
            },
          );
        },
      ),
    );
  }
}
