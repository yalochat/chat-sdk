// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/message.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MessageList extends StatefulWidget {
  const MessageList({super.key});

  @override
  State<MessageList> createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_handleControllerNotification);
    super.initState();
  }

  void _handleControllerNotification() {
    if (_scrollController.position.pixels >
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<ChatBloc>().add(
        ChatLoadMessages(direction: PageDirection.next),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return BlocSelector<ChatBloc, ChatState, (List<ChatMessage>, bool)>(
      // Subscribe to messageListVersion to detect changes in state.messages
      selector: (state) =>
          (state.messages, state.isLoading),
      builder: (context, state) {
        final (messages, isLoading) = state;
        return Container(
          color: chatThemeCubit.chatTheme.backgroundColor,
          padding: EdgeInsets.only(bottom: SdkConstants.messageListPadding),
          child: ListView.builder(
            reverse: true,
            itemCount: messages.length + (isLoading ? 1 : 0),
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index == messages.length) {
                return Center(child: CircularProgressIndicator());
              }
              return Container(
                margin: EdgeInsets.only(top: SdkConstants.messageListMargin),
                child: Message(
                  key: ValueKey(messages[index].id),
                  messageToRender: messages[index],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
