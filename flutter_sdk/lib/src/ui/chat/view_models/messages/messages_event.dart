// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:equatable/equatable.dart';

sealed class MessagesEvent {
  const MessagesEvent();
}

enum PageDirection { initial, next }

// Event that should be called to load messages in the chat
final class ChatLoadMessages extends MessagesEvent with EquatableMixin {
  final PageDirection direction;

  const ChatLoadMessages({this.direction = PageDirection.initial});
  @override
  List<Object?> get props => [direction];
}

// Event that is emitted when the agent starts typing
final class ChatStartTyping extends MessagesEvent with EquatableMixin {
  final String chatStatusText;

  ChatStartTyping({this.chatStatusText = ''});

  @override
  List<Object?> get props => [chatStatusText];
}

// Event that is emitted when the agent stops typing
final class ChatStopTyping extends MessagesEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that is emitted to update the user message
final class ChatUpdateUserMessage extends MessagesEvent with EquatableMixin {
  // The value to set to the user message.
  final String value;

  const ChatUpdateUserMessage({required this.value});

  @override
  List<Object?> get props => [value];
}

// Event to send a text message
final class ChatSendTextMessage extends MessagesEvent with EquatableMixin {
  ChatSendTextMessage();
  @override
  List<Object?> get props => [];
}


// Event to send a voice message
final class ChatSendVoiceMessage extends MessagesEvent with EquatableMixin {
  final List<double> amplitudes;
  final String fileName;
  final int duration;
  ChatSendVoiceMessage({
    required this.amplitudes,
    required this.fileName,
    required this.duration,
  });
  @override
  List<Object?> get props => [amplitudes, fileName, duration];
}


// Event to send a image message
final class ChatSendImageMessage extends MessagesEvent with EquatableMixin {
  final String fileName;
  final String text;

  ChatSendImageMessage({required this.fileName, required this.text});
  @override
  List<Object?> get props => [fileName, text];
}

// Event that is emitted to clear the messages
final class ChatClearMessages extends MessagesEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
