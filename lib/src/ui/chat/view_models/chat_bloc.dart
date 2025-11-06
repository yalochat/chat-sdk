// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_event.dart';
import 'chat_state.dart';

/// A Bloc for managing the chat state
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc()
    : super(
        ChatState(
          isConnected: false,
          isUserRecordingAudio: false,
          isSystemTypingMessage: false,
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
      emit(state.copyWith(isSystemTypingMessage: true));
    }
  }

  void _handleStopTyping(ChatStopTyping event, Emitter<ChatState> emit) {
    if (state.isSystemTypingMessage) {
      emit(state.copyWith(isSystemTypingMessage: false));
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
        messages: [...state.messages, trimmedMessage],
        userMessage: '',
      ),
    );
  }

  void _handleClearMessages(ChatClearMessages event, Emitter<ChatState> emit) {
    if (state.messages.isEmpty) return;
    emit(state.copyWith(messages: []));
  }
}
