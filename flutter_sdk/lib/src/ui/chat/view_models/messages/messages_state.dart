// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus {
  initial,
  success,
  failure,
  offline,
  failedMessageSent,
  failedRecordMessage,
}

class MessagesState extends Equatable {
  final List<ChatMessage> messages;

  final String userMessage;
  final bool isConnected;
  final bool isLoading;
  final bool isSystemTypingMessage;
  final String chatTitle;
  final ChatStatus chatStatus;
  final String chatStatusText;
  final PageInfo pageInfo;

  MessagesState({
    List<ChatMessage>? messages,
    this.userMessage = '',
    this.isConnected = false,
    this.isLoading = false,
    this.isSystemTypingMessage = false,
    this.chatTitle = '',
    this.chatStatus = ChatStatus.initial,
    this.chatStatusText = '',
    this.pageInfo = const PageInfo(
      cursor: null,
      pageSize: 30,
      nextCursor: null,
    ),
  }) : messages = messages ?? <ChatMessage>[];

  MessagesState copyWith({
    List<ChatMessage>? messages,
    String? userMessage,
    bool? isConnected,
    bool? isLoading,
    bool? isSystemTypingMessage,
    String? chatTitle,
    ChatStatus? chatStatus,
    String? chatStatusText,
    PageInfo? pageInfo,
  }) {
    return MessagesState(
      messages: messages ?? this.messages,
      userMessage: userMessage ?? this.userMessage,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      isSystemTypingMessage:
          isSystemTypingMessage ?? this.isSystemTypingMessage,
      chatTitle: chatTitle ?? this.chatTitle,
      chatStatus: chatStatus ?? this.chatStatus,
      chatStatusText: chatStatusText ?? this.chatStatusText,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    userMessage,
    isConnected,
    isLoading,
    isSystemTypingMessage,
    chatTitle,
    chatStatus,
    chatStatusText,
    pageInfo,
  ];
}
