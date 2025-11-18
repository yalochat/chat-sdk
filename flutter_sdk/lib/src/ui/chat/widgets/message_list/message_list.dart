// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return BlocSelector<ChatBloc, ChatState, List<ChatMessage>>(
      selector: (state) => state.messages,
      builder: (context, messages) {
        return Container(
          color: chatThemeCubit.chatTheme.backgroundColor,
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (context, index) {
              return Message(messageToRender: messages[index]);
            },
          ),
        );
      },
    );
  }
}
