// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';

import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/data/services/database/database_service.dart'
    as db;

import 'chat_message_repository.dart';

class MessageRepositoryLocal extends MessageRepository {
  final db.DatabaseService _databaseService;

  MessageRepositoryLocal({required db.DatabaseService localDatabaseService})
    : _databaseService = localDatabaseService;

  @override
  Future<Result<Page<ChatMessage>>> getChatMessagePage(
    int cursor,
    int pageSize,
  ) async {
    try {
      var results = await _databaseService
          .getMessagesPage(cursor, pageSize)
          .get();

      var data = results
          .map(
            (data) => ChatMessage(
              id: data.id,
              role: MessageRole.values.firstWhere(
                (role) => role.role == data.role,
              ),
              content: data.content,
              type: MessageType.values.firstWhere(
                (type) => type.type == data.type,
              ),
              status: MessageStatus.values.firstWhere(
                (status) => status.status == data.status,
              ),
              timestamp: DateTime.fromMillisecondsSinceEpoch(data.timestamp),
            ),
          )
          .toList();

      int? nextCursor;
      if (data.isNotEmpty) {
        nextCursor = data.last.id;
      }
      return Result.ok(
        Page(
          data: data,
          pageInfo: PageInfo(
            cursor: cursor,
            nextCursor: nextCursor,
            pageSize: pageSize,
          ),
        ),
      );
    } catch (e) {
      return Result.error(e as Exception);
    }
  }

  @override
  Future<Result<ChatMessage>> insertMessage(ChatMessage message) async {
    try {
      var resultId = await _databaseService
          .into(_databaseService.chatMessage)
          .insert(
            db.ChatMessageCompanion.insert(
              role: message.role.role,
              content: message.content,
              type: message.type.type,
              status: message.status.status,
              timestamp: message.timestamp.millisecondsSinceEpoch,
            ),
          );
      return Result.ok(message.copyWith(id: resultId));
    } catch (e) {
      return Result.error(e as Exception);
    }
  }
}
