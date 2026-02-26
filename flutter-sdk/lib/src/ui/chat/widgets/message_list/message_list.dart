// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
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
      context.read<MessagesBloc>().add(
        ChatLoadMessages(direction: PageDirection.next),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return BlocSelector<MessagesBloc, MessagesState, (int, bool)>(
      selector: (state) => (state.messages.length, state.isLoading),
      builder: (context, state) {
        final (length, isLoading) = state;
        return Container(
          color: chatThemeCubit.chatTheme.backgroundColor,
          padding: EdgeInsets.only(bottom: SdkConstants.messageListPadding),
          child: ListView.builder(
            key: Key('chat_messages'),
            reverse: true,
            cacheExtent: SdkConstants.chatCacheExtent,
            itemCount: length + (isLoading ? 1 : 0),
            controller: _scrollController,
            itemBuilder: (context, index) {
              if (index == length) {
                return Center(
                  child: CircularProgressIndicator(
                    key: const Key('loading_spinner'),
                  ),
                );
              }
              return Container(
                margin: EdgeInsets.only(top: SdkConstants.messageListMargin),
                child: BlocSelector<MessagesBloc, MessagesState, ChatMessage>(
                  selector: (state) => state.messages[index],
                  builder: (context, message) {
                    assert(
                      message.id != null,
                      'Message id must not be null in order to render',
                    );
                    return Message(
                      key: ValueKey('message-item-${message.id}'),
                      messageToRender: message,
                    );
                  },
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
