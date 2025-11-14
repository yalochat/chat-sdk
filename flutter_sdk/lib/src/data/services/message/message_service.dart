// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/data/common/result.dart';

import 'chat_message.dart';


// A service that provides chat messages from a data source
abstract class MessageService {


  // Used to initialize resources opened by this service
  Future<void> init();

  // Get chats from a data source
  Future<Result<List<ChatMessage>>> getChatMessages(int limit);

}
