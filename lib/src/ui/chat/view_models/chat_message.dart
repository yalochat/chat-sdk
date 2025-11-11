// Copyright (c) Yalochat, Inc. All rights reserved.

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

class ChatMessage {
  final int id;
  final MessageRole role;
  final String text;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.role,
    required this.type,
    required this.timestamp,
    this.text = '',
    this.status = MessageStatus.inProgress,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatMessage &&
        other.id == id &&
        other.role == role &&
        other.text == text &&
        other.type == type &&
        other.status == status &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(id, role, text, type, status, timestamp);
  }

  @override
  String toString() {
    return 'ChatMessage(id: $id, role: ${role.role}, text: "$text", type: ${type.type}, status: $status, timestamp: $timestamp)';
  }
}


