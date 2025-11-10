// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/foundation.dart';

class ChatState {
  final List<String> messages;
  final String userMessage;
  final bool isConnected;
  final bool isSystemTypingMessage;
  final bool isUserRecordingAudio;

  ChatState({
    this.messages = const <String>[],
    this.userMessage = "",
    this.isConnected = false,
    this.isSystemTypingMessage = false,
    this.isUserRecordingAudio = false,
  });

  ChatState copyWith({
    List<String>? messages,
    String? userMessage,
    bool? isConnected,
    bool? isSystemTypingMessage,
    bool? isUserRecordingAudio,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      userMessage: userMessage ?? this.userMessage,
      isConnected: isConnected ?? this.isConnected,
      isSystemTypingMessage:
          isSystemTypingMessage ?? this.isSystemTypingMessage,
      isUserRecordingAudio: isUserRecordingAudio ?? this.isUserRecordingAudio,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ChatState) return false;

    return listEquals(messages, other.messages) &&
        userMessage == other.userMessage &&
        isConnected == other.isConnected &&
        isSystemTypingMessage == other.isSystemTypingMessage &&
        isUserRecordingAudio == other.isUserRecordingAudio;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(messages),
    userMessage,
    isConnected,
    isSystemTypingMessage,
    isUserRecordingAudio,
  );
}
