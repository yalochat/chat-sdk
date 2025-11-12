// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

enum MessageRole {
  user(role: 'USER'),
  system(role: 'SYSTEM'),
  assistant(role: 'ASSISTANT');

  final String role;

  const MessageRole({required this.role});
}

enum MessageType {
  text(type: 'text'),
  image(type: 'image'),
  voice(type: 'voice');

  final String type;
  const MessageType({required this.type});
}

enum MessageStatus { delivered, read, error, sent, inProgress }

class ChatMessage extends Equatable {
  final int id;
  final MessageRole role;
  final String text;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.role,
    required this.type,
    required this.timestamp,
    this.text = '',
    this.status = MessageStatus.inProgress,
  });

  @override
  List<Object?> get props => [id, role, text, type, status, timestamp];
}


