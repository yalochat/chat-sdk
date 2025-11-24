// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart' show SdkConstants;
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_event.dart';
import 'chat_state.dart';

/// A Bloc for managing the chat state of the Chat Widget of the SDK.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Clock _clock;
  final ChatMessageRepository _chatMessageRepository;

  ChatBloc({
    String name = '',
    required ChatMessageRepository chatMessageRepository,
    int pageSize = SdkConstants.defaultPageSize,
    Clock? clock,
  }) : _clock = clock ?? Clock(),
       _chatMessageRepository = chatMessageRepository,
       super(
         ChatState(
           isConnected: false,
           isUserRecordingAudio: false,
           isSystemTypingMessage: false,
           chatTitle: name,
           pageInfo: PageInfo(pageSize: pageSize),
         ),
       ) {
    on<ChatLoadMessages>(_handleFetchMessages);
    on<ChatStartTyping>(_handleStartTyping);
    on<ChatStopTyping>(_handleStopTyping);
    on<ChatUpdateUserMessage>(_handleUpdateUserMessage);
    on<ChatSendMessage>(_handleSendMessage);
    on<ChatClearMessages>(_handleClearMessages);
  }

  // Event that handles the pagination of messages
  Future<void> _handleFetchMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    int? cursor;
    switch (event.direction) {
      case PageDirection.next:
        cursor = state.pageInfo.nextCursor;
        // No more pages
        if (cursor == null) {
          emit(state.copyWith(isLoading: false));
          return;
        }
      case PageDirection.initial:
      // Keep the cursor null
    }

    Result<Page<ChatMessage>> newMessages = await _chatMessageRepository
        .getChatMessagePageDesc(cursor, state.pageInfo.pageSize);
    switch (newMessages) {
      case Ok<Page<ChatMessage>>():
        emit(
          state.copyWith(
            chatStatus: ChatStatus.success,
            // FIXME: Create a new way to track big message list copies
            messages: [...state.messages, ...newMessages.result.data],
            isLoading: false,
            pageInfo: newMessages.result.pageInfo.copyWith(
              prevCursor: state.pageInfo.cursor,
            ),
          ),
        );
        break;
      case Error<Page<ChatMessage>>():
        emit(state.copyWith(chatStatus: ChatStatus.failure, isLoading: false));
        break;
    }
  }

  // Handles the event when the assistant starts typing.
  void _handleStartTyping(ChatStartTyping event, Emitter<ChatState> emit) {
    if (!state.isSystemTypingMessage) {
      emit(
        state.copyWith(
          isSystemTypingMessage: true,
          chatStatusText: event.chatStatusText,
        ),
      );
    }
  }

  // Handles the event when the assistant stops typing.
  void _handleStopTyping(ChatStopTyping event, Emitter<ChatState> emit) {
    if (state.isSystemTypingMessage) {
      emit(state.copyWith(isSystemTypingMessage: false, chatStatusText: ''));
    }
  }

  // Handles the event to update the user message
  void _handleUpdateUserMessage(
    ChatUpdateUserMessage event,
    Emitter<ChatState> emit,
  ) {
    if (event.value != state.userMessage) {
      emit(state.copyWith(userMessage: event.value));
    }
  }

  // Handles the event when the user sends a message
  Future<void> _handleSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final String trimmedMessage = state.userMessage.trim();
    if (trimmedMessage.isEmpty) return;
    ChatMessage messageToInsert = ChatMessage(
      role: MessageRole.user,
      type: MessageType.text,
      content: trimmedMessage,
      timestamp: _clock.now(),
    );
    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );

    switch (result) {
      case Ok<ChatMessage>():
        emit(
          state.copyWith(
            // FIXME: Create a new way to track big message list copies
            messages: [result.result, ...state.messages],
            userMessage: '',
            chatStatusText: 'Typing...',
          ),
        );
        break;
      case Error<ChatMessage>():
        emit(state.copyWith(chatStatus: ChatStatus.failedMessageSent));
        break;
    }
  }

  // Handles the event to clear messages.
  void _handleClearMessages(ChatClearMessages event, Emitter<ChatState> emit) {
    if (state.messages.isEmpty) return;
    emit(state.copyWith(messages: []));
    // TODO: Add the repository to clear messages
  }
}
