// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/data/common/page.dart';
import 'package:chat_flutter_sdk/src/data/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/message/chat_message.dart';

abstract class MessageRepository {
  Future<Result<Page<ChatMessage>>>  getChatMessagePage(int page, int pageSize);
  Future<Result<ChatMessage>> insertMessage(ChatMessage message);
}
