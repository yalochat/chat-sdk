// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

enum MessageRole {
  user('USER'),
  assistant('ASSISTANT');

  final String role;

  const MessageRole(this.role);
}

enum MessageType {
  text('text'),
  image('image'),
  voice('voice');

  final String type;
  const MessageType(this.type);
}

enum MessageStatus {
  delivered('DELIVERED'),
  read('READ'),
  error('ERROR'),
  sent('SENT'),
  inProgress('IN_PROGRESS');

  final String status;
  const MessageStatus(this.status);
}

// A class that represents a chat message in the chat
class ChatMessage extends Equatable {
  final int? id;
  final MessageRole role;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;

  const ChatMessage({
    this.id,
    required this.role,
    required this.type,
    required this.timestamp,
    this.content = '',
    this.status = MessageStatus.inProgress,
  });

  // Creates a copy of a chat message
  ChatMessage copyWith({
      int? id,
      MessageRole? role,
      String? content,
      MessageType? type,
      MessageStatus? status,
      DateTime? timestamp,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  // Equatable props array
  @override
  List<Object?> get props => [id, role, content, type, status, timestamp];
}
