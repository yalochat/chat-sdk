// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:equatable/equatable.dart';

sealed class ChatEvent {
  const ChatEvent();
}

final class ChatStartTyping extends ChatEvent with EquatableMixin {
  final String chatStatus;

  ChatStartTyping({this.chatStatus = ''});

  @override
  List<Object?> get props => [chatStatus];
}

final class ChatStopTyping extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ChatUpdateUserMessage extends ChatEvent with EquatableMixin {
  final String value;

  const ChatUpdateUserMessage({required this.value});

  @override
  List<Object?> get props => [value];
}

final class ChatSendMessage extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

final class ChatClearMessages extends ChatEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
