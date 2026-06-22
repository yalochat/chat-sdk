// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/rendering.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/message.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/quick_replies.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/typing_indicator.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/constants.dart';
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
    return BlocSelector<MessagesBloc, MessagesState, (int, bool, bool)>(
      selector: (state) =>
          (state.messages.length, state.isLoading, state.isAwaitingResponse),
      builder: (context, state) {
        final (length, isLoading, isAwaitingResponse) = state;
        // The list is reversed, so index 0 sits at the bottom. We reserve
        // index 0 for the typing indicator when awaiting a server reply and
        // the trailing slot for the pagination spinner.
        final int typingOffset = isAwaitingResponse ? 1 : 0;
        final int paginationOffset = isLoading ? 1 : 0;
        return Container(
          color: chatThemeCubit.chatTheme.backgroundColor,
          padding: EdgeInsets.only(bottom: SdkConstants.messageListPadding),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  key: Key('chat_messages'),
                  reverse: true,
                  scrollCacheExtent: ScrollCacheExtent.pixels(
                    SdkConstants.chatCacheExtent,
                  ),
                  itemCount: length + typingOffset + paginationOffset,
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (isAwaitingResponse && index == 0) {
                      return const TypingIndicator();
                    }
                    final int messageIndex = index - typingOffset;
                    if (messageIndex == length) {
                      return Center(
                        child: CircularProgressIndicator(
                          key: const Key('loading_spinner'),
                        ),
                      );
                    }
                    return Container(
                      margin: EdgeInsets.only(
                        top: SdkConstants.messageListMargin,
                      ),
                      child:
                          BlocSelector<
                            MessagesBloc,
                            MessagesState,
                            ChatMessage
                          >(
                            selector: (state) => state.messages[messageIndex],
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
              ),
              const QuickReplies(),
            ],
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
