// Copyright (c) Yalochat, Inc. All rights reserved.


import 'package:chat_flutter_sdk/src/data/common/page.dart';
import 'package:chat_flutter_sdk/src/data/common/result.dart';

import 'package:chat_flutter_sdk/src/data/services/message/chat_message.dart';

import 'message_repository.dart';

class MessageRepositoryLocal extends MessageRepository {

  @override
  Future<Result<Page<ChatMessage>>> getChatMessagePage(int page, int pageSize) async {
    throw UnimplementedError();
  }

  @override
  Future<Result<ChatMessage>> insertMessage(ChatMessage message) async {
    throw UnimplementedError();
  }
}
