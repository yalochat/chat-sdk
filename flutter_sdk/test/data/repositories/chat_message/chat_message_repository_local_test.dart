// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/exceptions/range_exception.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository_local.dart';
import 'package:chat_flutter_sdk/src/data/services/database/database_service.dart'
    hide ChatMessage;
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:clock/clock.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class DatabaseServiceMock extends Mock implements DatabaseService {}

void main() {
  group('ChatMessageRepositoryLocal integration tests', () {
    late ChatMessageRepository chatRepository;
    late DatabaseService databaseService;
    setUp(() {
      databaseService = DatabaseService(
        DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      );
      chatRepository = ChatMessageRepositoryLocal(
        localDatabaseService: databaseService,
      );
    });

    tearDown(() {
      databaseService.close();
    });

    test('should store a chat message successfully', () async {
      ChatMessage message = ChatMessage(
        role: MessageRole.user,
        type: MessageType.text,
        content: 'Test content',
        timestamp: clock.now(),
      );
      var result = await chatRepository.insertChatMessage(message);
      expect(result, isA<Ok<ChatMessage>>());
      var okRes = result as Ok<ChatMessage>;
      expect(okRes.result.id, equals(1));
    }, tags: ['integration']);

    test(
      'should store multiple message successfully and return them correctly, no nextCursor because pageSize > n',
      () async {
        ChatMessage message = ChatMessage(
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test content',
          timestamp: clock.now(),
        );
        ChatMessage voiceMessage = ChatMessage.voice(
          role: MessageRole.user,
          timestamp: clock.now(),
          fileName: 'test.wav',
          amplitudes: [2.0, 3.0],
          duration: 300,
        );
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(voiceMessage);
        await chatRepository.insertChatMessage(voiceMessage);

        var results = await chatRepository.getChatMessagePageDesc(null, 5);
        expect(results, isA<Ok<Page<ChatMessage>>>());

        var resultPage = (results as Ok<Page<ChatMessage>>).result;
        expect(resultPage.data.length, equals(4));
        expect(
          resultPage.pageInfo,
          equals(PageInfo(cursor: null, pageSize: 5)),
        );
      },
      tags: ['integration'],
    );

    test(
      'should return nextCursor correctly when there are more elements than the pageSize',
      () async {
        ChatMessage message = ChatMessage(
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test content',
          timestamp: clock.now(),
        );
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);

        var results = await chatRepository.getChatMessagePageDesc(null, 3);
        expect(results, isA<Ok<Page<ChatMessage>>>());
        var resultPage = (results as Ok<Page<ChatMessage>>).result;
        expect(resultPage.data.length, equals(3));
        expect(
          resultPage.pageInfo,
          equals(PageInfo(cursor: null, pageSize: 3, nextCursor: 2)),
        );
      },
      tags: ['integration'],
    );

    test('should return middle page correctly', () async {
      ChatMessage message = ChatMessage(
        role: MessageRole.user,
        type: MessageType.text,
        content: 'Test content',
        timestamp: clock.now(),
      );
      await chatRepository.insertChatMessage(message);
      await chatRepository.insertChatMessage(message);
      await chatRepository.insertChatMessage(message);
      await chatRepository.insertChatMessage(message);

      var results = await chatRepository.getChatMessagePageDesc(4, 1);
      expect(results, isA<Ok<Page<ChatMessage>>>());
      var resultPage = (results as Ok<Page<ChatMessage>>).result;
      expect(resultPage.data.length, equals(1));
      expect(
        resultPage.pageInfo,
        equals(PageInfo(cursor: 4, pageSize: 1, nextCursor: 3)),
      );
    }, tags: ['integration']);

    test(
      'should return the last page correctly without a nextCursor',
      () async {
        ChatMessage message = ChatMessage(
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test content',
          timestamp: clock.now(),
        );
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);

        var results = await chatRepository.getChatMessagePageDesc(2, 1);
        expect(results, isA<Ok<Page<ChatMessage>>>());
        var resultPage = (results as Ok<Page<ChatMessage>>).result;
        expect(resultPage.data.length, equals(1));
        expect(
          resultPage.pageInfo,
          equals(PageInfo(cursor: 2, pageSize: 1, nextCursor: null)),
        );
      },
      tags: ['integration'],
    );

    test(
      'should throw an error if the cursor or page size is negative when getting messages',
      () async {
        ChatMessage message = ChatMessage(
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test content',
          timestamp: clock.now(),
        );
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);

        var results = await chatRepository.getChatMessagePageDesc(-1, 3);
        expect(
          results,
          isA<Error<Page<ChatMessage>>>().having(
            (e) => e.error,
            'returned error',
            isA<RangeException>(),
          ),
        );
        results = await chatRepository.getChatMessagePageDesc(0, -1);
        expect(
          results,
          isA<Error<Page<ChatMessage>>>().having(
            (e) => e.error,
            'returned error',
            isA<RangeException>(),
          ),
        );
      },
      tags: ['integration'],
    );

    test(
      'should throw an error if two messages with the same id are inserted',
      () async {
        ChatMessage message = ChatMessage(
          id: 2,
          role: MessageRole.user,
          type: MessageType.text,
          content: 'Test content',
          timestamp: clock.now(),
        );
        try {
          await chatRepository.insertChatMessage(message);
          await chatRepository.insertChatMessage(message);
          fail('should fail inserting two messages with the same id');
        } catch (e) {
          expect(e, isA<Exception>());
        }
      },
      tags: ['integration'],
    );
  });

  group('ChatMessageRepositoryLocal unit tests', () {
    late ChatMessageRepository chatRepository;
    late DatabaseService databaseService;
    setUp(() {
      databaseService = DatabaseServiceMock();
      chatRepository = ChatMessageRepositoryLocal(
        localDatabaseService: databaseService,
      );
    });

    test('should throw an error when insertion fails', () async {
      ChatMessage message = ChatMessage(
        id: 2,
        role: MessageRole.user,
        type: MessageType.text,
        content: 'Test content',
        timestamp: clock.now(),
      );

      when(
        () => databaseService.into(databaseService.chatMessage).insert(any()),
      ).thenThrow(Exception('test'));
      var result = await chatRepository.insertChatMessage(message);
      expect(result, isA<Error<ChatMessage>>());
    });

    test('should throw an error when select statement fails', () async {
      when(
        () => databaseService.getMessagesPage(0, 2),
      ).thenThrow(Exception('test'));
      var result = await chatRepository.getChatMessagePageDesc(0, 1);
      expect(result, isA<Error<Page<ChatMessage>>>());
    });
  });
}
