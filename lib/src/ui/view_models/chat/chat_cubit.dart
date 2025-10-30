// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter_bloc/flutter_bloc.dart';

import 'chat_state.dart';

/// A Cubit for managing the chat state
class ChatCubit extends Cubit<ChatState> {
  ChatCubit()
    : super(
        ChatState(
          isConnected: false,
          isRecordingAudio: false,
          isTypingMessage: false,
        ),
      );

  void startTyping() => emit(state.copyWith(isTypingMessage: true));
  void stopTyping() => emit(state.copyWith(isTypingMessage: false));

  void updateUserMessage(String value) {
    emit(state.copyWith(userMessage: value));
  }

  void addMessage() {
    emit(state.copyWith(messages: [...state.messages, state.userMessage]));
  }
}
