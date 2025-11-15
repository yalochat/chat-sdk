// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';

abstract class MessageRepository {
  Future<Result<Page<ChatMessage>>> getChatMessagePage(int cursor, int pageSize);
  Future<Result<ChatMessage>> insertMessage(ChatMessage message);
}
