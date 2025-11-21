// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

sealed class ChatEvent {
  const ChatEvent();
}

enum PageDirection { initial, next}

// Event that should be called to load messages in the chat
final class ChatLoadMessages extends ChatEvent with EquatableMixin {
  final PageDirection direction;

  const ChatLoadMessages({this.direction = PageDirection.initial});
  @override
  List<Object?> get props => [];
}

// Event that is emitted when the agent starts typing
final class ChatStartTyping extends ChatEvent with EquatableMixin {
  final String chatStatusText;

  ChatStartTyping({this.chatStatusText = ''});

  @override
  List<Object?> get props => [chatStatusText];
}

// Event that is emitted when the agent stops typing
final class ChatStopTyping extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that is emitted to update the user message
final class ChatUpdateUserMessage extends ChatEvent with EquatableMixin {
  // The value to set to the user message.
  final String value;

  const ChatUpdateUserMessage({required this.value});

  @override
  List<Object?> get props => [value];
}

// Event that is emitted when the user sends a messages
final class ChatSendMessage extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that is emitted to clear the messages
final class ChatClearMessages extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
