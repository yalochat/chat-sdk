// Copyright (c) Yalochat, Inc. All rights reserved.

// A service that interacts with a sqlite database
// to manage chat messages locally
import 'package:chat_flutter_sdk/src/data/common/result.dart';
import 'package:sqflite/sqflite.dart';

import 'chat_message.dart';
import 'message_service.dart';

class MessageServiceLocal extends MessageService {
  final Database db;

  MessageServiceLocal({required this.db});

  @override
  Future<Result<List<ChatMessage>>> getChatMessages(int limit) {
    
  }

  // Creates the dabase tables for chat messages
  @override
  Future<void> init() async {
    await db.execute(
      'CREATE TABLE chat_message (id INTEGER PRIMARY KEY, role TEXT, content TEXT, type TEXT, status TEXT, timestamp NUMERIC)',
    );
  }
}
