// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_message.dart';
import 'package:flutter/foundation.dart';


class ChatState {
  final List<ChatMessage> messages;
  final String userMessage;
  final bool isConnected;
  final bool isSystemTypingMessage;
  final bool isUserRecordingAudio;
  final String chatTitle;
  final String chatStatus;

  ChatState({
    this.messages = const <ChatMessage>[],
    this.userMessage = "",
    this.isConnected = false,
    this.isSystemTypingMessage = false,
    this.isUserRecordingAudio = false,
    this.chatTitle = '',
    this.chatStatus = '',
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    String? userMessage,
    bool? isConnected,
    bool? isSystemTypingMessage,
    bool? isUserRecordingAudio,
    String? chatTitle,
    String? chatStatus,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      userMessage: userMessage ?? this.userMessage,
      isConnected: isConnected ?? this.isConnected,
      isSystemTypingMessage:
          isSystemTypingMessage ?? this.isSystemTypingMessage,
      isUserRecordingAudio: isUserRecordingAudio ?? this.isUserRecordingAudio,
      chatTitle: chatTitle ?? this.chatTitle,
      chatStatus: chatStatus ?? this.chatStatus,
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
        isUserRecordingAudio == other.isUserRecordingAudio &&
        chatTitle == other.chatTitle &&
        chatStatus == other.chatStatus;
  }

  @override
  int get hashCode => Object.hash(
    Object.hashAll(messages),
    userMessage,
    isConnected,
    isSystemTypingMessage,
    isUserRecordingAudio,
    chatTitle,
    chatStatus,
  );
}
