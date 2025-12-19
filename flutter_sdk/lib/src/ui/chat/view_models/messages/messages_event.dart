// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:equatable/equatable.dart';

sealed class MessagesEvent {
  const MessagesEvent();
}

enum PageDirection { initial, next }

enum UnitType { unit, subunit }

// Event that should be called to load messages in the chat
final class ChatLoadMessages extends MessagesEvent with EquatableMixin {
  final PageDirection direction;

  const ChatLoadMessages({this.direction = PageDirection.initial});
  @override
  List<Object?> get props => [direction];
}

// Event that is emitted to subscribe to yalo messages events
final class ChatSubscribeToEvents extends MessagesEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that is emitted to subscribe to yalo messages messages
final class ChatSubscribeToMessages extends MessagesEvent with EquatableMixin {
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

// Event to add a quantity to a product
final class ChatUpdateProductQuantity extends MessagesEvent
    with EquatableMixin {
  final int messageId;
  final String productSku;
  final UnitType unitType;
  final double quantity;

  ChatUpdateProductQuantity({
    required this.messageId,
    required this.productSku,
    required this.unitType,
    required this.quantity,
  });

  @override
  List<Object?> get props => [messageId, productSku, unitType, quantity];
}

final class ChatToggleMessageExpand extends MessagesEvent with EquatableMixin {
  final int messageId;

  ChatToggleMessageExpand({required this.messageId});

  @override
  List<Object?> get props => [];
}

// Event to send a text message
final class ChatSendTextMessage extends MessagesEvent with EquatableMixin {
  ChatSendTextMessage();
  @override
  List<Object?> get props => [];
}

// Event to send a voice message
final class ChatSendVoiceMessage extends MessagesEvent with EquatableMixin {
  final AudioData audioData;
  ChatSendVoiceMessage({required this.audioData});
  @override
  List<Object?> get props => [audioData];
}

// Event to send a image message
final class ChatSendImageMessage extends MessagesEvent with EquatableMixin {
  final ImageData imageData;
  final String text;

  ChatSendImageMessage({required this.imageData, required this.text});
  @override
  List<Object?> get props => [imageData, text];
}

// Event that is emitted to clear the messages
final class ChatClearMessages extends MessagesEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
