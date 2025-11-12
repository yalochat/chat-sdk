// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_message.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_event.dart';
import 'chat_state.dart';

/// A Bloc for managing the chat state
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Clock clock;
  final String name;
  ChatBloc({this.name = '', Clock? clock})
    : clock = clock ?? Clock(), super(
        ChatState(
          isConnected: false,
          isUserRecordingAudio: false,
          isSystemTypingMessage: false,
          chatTitle: name,
        ),
      ) {
    on<ChatStartTyping>(_handleStartTyping);
    on<ChatStopTyping>(_handleStopTyping);
    on<ChatUpdateUserMessage>(_handleUpdateUserMessage);
    on<ChatSendMessage>(_handleSendMessage);
    on<ChatClearMessages>(_handleClearMessages);
  }

  void _handleStartTyping(ChatStartTyping event, Emitter<ChatState> emit) {
    if (!state.isSystemTypingMessage) {
      emit(
        state.copyWith(
          isSystemTypingMessage: true,
          chatStatus: event.chatStatus,
        ),
      );
    }
  }

  void _handleStopTyping(ChatStopTyping event, Emitter<ChatState> emit) {
    if (state.isSystemTypingMessage) {
      emit(state.copyWith(isSystemTypingMessage: false, chatStatus: ''));
    }
  }

  void _handleUpdateUserMessage(
    ChatUpdateUserMessage event,
    Emitter<ChatState> emit,
  ) {
    if (event.value != state.userMessage) {
      emit(state.copyWith(userMessage: event.value));
    }
  }

  void _handleSendMessage(ChatSendMessage event, Emitter<ChatState> emit) {
    final String trimmedMessage = state.userMessage.trim();
    if (trimmedMessage.isEmpty) return;
    emit(
      state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(
            id: state.messages.length,
            role: MessageRole.user,
            type: MessageType.text,
            text: trimmedMessage,
            timestamp: clock.now(),
          ),
        ],
        userMessage: '',
      ),
    );
  }

  void _handleClearMessages(ChatClearMessages event, Emitter<ChatState> emit) {
    if (state.messages.isEmpty) return;
    emit(state.copyWith(messages: []));
  }
}
