// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';

// Yalo message repository load messages from yalo's workflow interpreter
// adapter and translate it to ChatMessage domain model
abstract class YaloMessageRepository {
  // Streams chat messages from yalo's adapter
  Stream<ChatMessage> messages();

  // Stream chat
  Stream<ChatEvent> events();

  // Sends message to yalo's workflow interpreter adapter
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage);

  // Method to free resources
  void dispose();
}
