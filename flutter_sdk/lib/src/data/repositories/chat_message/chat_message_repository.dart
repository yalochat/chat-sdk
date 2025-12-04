// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';

// A repository that handles chat messages in a data source.
abstract class ChatMessageRepository {
  // Method to get chat pages in descending order, a null cursor provides the first page
  // subsequent calls should include the cursor returned inside the PageInfo
  Future<Result<Page<ChatMessage>>> getChatMessagePageDesc(int? cursor, int pageSize);

  // Inserts a chat message to the data source.
  Future<Result<ChatMessage>> insertChatMessage(ChatMessage message);

  // TODO: Add clear messages
}
