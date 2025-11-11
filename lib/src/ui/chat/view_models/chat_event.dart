// Copyright (c) Yalochat, Inc. All rights reserved.

sealed class ChatEvent {
  const ChatEvent();
}

final class ChatStartTyping extends ChatEvent {
  final String chatStatus;

  ChatStartTyping({this.chatStatus = ''});
}

final class ChatStopTyping extends ChatEvent {}

final class ChatUpdateUserMessage extends ChatEvent {
  final String value;

  const ChatUpdateUserMessage({required this.value});
}

final class ChatSendMessage extends ChatEvent {}

final class ChatClearMessages extends ChatEvent {}
