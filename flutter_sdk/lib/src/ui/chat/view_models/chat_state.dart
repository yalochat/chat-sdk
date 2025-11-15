// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:equatable/equatable.dart';


class ChatState extends Equatable {
  final List<ChatMessage> messages;
  final String userMessage;
  final bool isConnected;
  final bool isSystemTypingMessage;
  final bool isUserRecordingAudio;
  final String chatTitle;
  final String chatStatus;

  const ChatState({
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
  List<Object?> get props => [messages, userMessage, isConnected, isSystemTypingMessage, isUserRecordingAudio, chatTitle, chatStatus];
}
