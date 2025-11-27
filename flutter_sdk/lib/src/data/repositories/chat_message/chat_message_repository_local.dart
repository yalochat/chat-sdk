// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/exceptions/range_exception.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/database/database_service.dart'
    hide ChatMessage;

import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/data/services/database/database_service.dart'
    as db;
import 'package:drift/drift.dart';

import 'chat_message_repository.dart';

class ChatMessageRepositoryLocal extends ChatMessageRepository {
  final db.DatabaseService _databaseService;

  ChatMessageRepositoryLocal({required db.DatabaseService localDatabaseService})
    : _databaseService = localDatabaseService;

  @override
  Future<Result<Page<ChatMessage>>> getChatMessagePageDesc(
    int? cursor,
    int pageSize,
  ) async {
    if (cursor != null && cursor < 0) {
      return Result.error(RangeException('Invalid cursor value', cursor, 0));
    }
    if (pageSize < 0) {
      return Result.error(
        RangeException('Invalid pageSize value', pageSize, 0),
      );
    }
    try {
      List<ChatMessageData> results;
      if (cursor == null) {
        results = await _databaseService
            .getMessagesFirstPage(pageSize + 1)
            .get();
      } else {
        results = await _databaseService
            .getMessagesPage(cursor, pageSize + 1)
            .get();
      }

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
              fileName: data.fileName,
              amplitudes: data.amplitudes != null
                  ? (jsonDecode(data.amplitudes!) as List)
                        .map((e) => e as double)
                        .toList()
                  : null,
              duration: data.duration,
              timestamp: DateTime.fromMillisecondsSinceEpoch(data.timestamp),
            ),
          )
          .toList();

      int? nextCursor;
      if (data.isNotEmpty && data.length > pageSize) {
        data.removeLast();
        nextCursor = data[data.length - 1].id;
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
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<ChatMessage>> insertChatMessage(ChatMessage message) async {
    try {
      var resultId = await _databaseService
          .into(_databaseService.chatMessage)
          .insert(
            db.ChatMessageCompanion.insert(
              id: message.id == null ? Value.absent() : Value(message.id!),
              role: message.role.role,
              content: message.content,
              type: message.type.type,
              status: message.status.status,
              fileName: message.fileName == null
                  ? Value.absent()
                  : Value(message.fileName),
              amplitudes: message.amplitudes == null
                  ? Value.absent()
                  : Value(jsonEncode(message.amplitudes)),
              duration: message.duration == null
                  ? Value.absent()
                  : Value(message.duration),
              timestamp: message.timestamp.millisecondsSinceEpoch,
            ),
          );
      return Result.ok(message.copyWith(id: resultId));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
