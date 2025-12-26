// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/domain/models/product/product.dart';
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
        ChatMessage productMessage = ChatMessage.product(
          role: MessageRole.user,
          timestamp: clock.now(),
          products: [
            Product(
              sku: '123',
              name: '123',
              price: 30.0,
              unitName: 'box',
            ),
          ],
        );

        ChatMessage carouselMessage = ChatMessage.carousel(
          role: MessageRole.user,
          timestamp: clock.now(),
          products: [
            Product(
              sku: '123',
              name: '123',
              price: 30.0,
              unitName: 'box',
            ),
          ],
        );

        ChatMessage imageMessage = ChatMessage.image(
          role: MessageRole.assistant,
          timestamp: clock.now(),
          fileName: 'test/image.png',
        );
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(message);
        await chatRepository.insertChatMessage(voiceMessage);
        await chatRepository.insertChatMessage(voiceMessage);
        await chatRepository.insertChatMessage(productMessage);
        await chatRepository.insertChatMessage(imageMessage);
        await chatRepository.insertChatMessage(carouselMessage);

        var results = await chatRepository.getChatMessagePageDesc(null, 700);
        expect(results, isA<Ok<Page<ChatMessage>>>());

        var resultPage = (results as Ok<Page<ChatMessage>>).result;
        expect(resultPage.data.length, equals(7));
        expect(
          resultPage.pageInfo,
          equals(PageInfo(cursor: null, pageSize: 700)),
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

    test('should replace a product message correctly', () async {
      ChatMessage message = ChatMessage.product(
        role: MessageRole.user,
        timestamp: clock.now(),
        products: [
          Product(
            sku: '123',
            name: '123',
            price: 30.0,
            unitName: 'box',
          ),
        ],
      );
      var result = await chatRepository.insertChatMessage(message);
      expect(result, isA<Ok<ChatMessage>>());
      var okRes = result as Ok<ChatMessage>;
      expect(okRes.result.id, equals(1));

      ChatMessage newMessage = okRes.result.copyWith(
        products: [
          Product(
            sku: '123',
            name: 'Test',
            price: 300,
            unitName: 'box',
          ),
        ],
      );

      final updateRes = await chatRepository.replaceChatMessage(newMessage);
      expect(
        updateRes,
        isA<Ok<bool>>().having((s) => s.result, 'value', equals(true)),
      );

      final actualRes = await (databaseService.select(
        databaseService.chatMessage,
      )..where((m) => m.id.equals(1))).getSingle();

      final List<Product> products = actualRes.products != null
          ? (jsonDecode(actualRes.products!) as List)
                .map((e) => Product.fromJson(e as Map<String, dynamic>))
                .toList()
          : [];

      expect(products.length, equals(1));
      expect(
        products[0],
        equals(
          Product(
            sku: '123',
            name: 'Test',
            price: 300,
            unitName: 'box',
          ),
        ),
      );
    }, tags: ['integration']);

    test(
      'should replace a generic message correctly, with a product message',
      () async {
        ChatMessage message = ChatMessage(
          role: MessageRole.user,
          timestamp: clock.now(),
          amplitudes: [3.0],
          duration: 1,
          products: [
            Product(
              sku: '123',
              name: '123',
              price: 30.0,
              unitName: 'box',
            ),
          ],
          type: MessageType.text,
        );
        var result = await chatRepository.insertChatMessage(message);
        expect(result, isA<Ok<ChatMessage>>());
        var okRes = result as Ok<ChatMessage>;
        expect(okRes.result.id, equals(1));

        ChatMessage newMessage = okRes.result.copyWith(
          products: [
            Product(
              sku: '123',
              name: 'Test',
              price: 300,
              unitName: 'box',
            ),
          ],
        );

        final updateRes = await chatRepository.replaceChatMessage(newMessage);
        expect(
          updateRes,
          isA<Ok<bool>>().having((s) => s.result, 'value', equals(true)),
        );

        final actualRes = await (databaseService.select(
          databaseService.chatMessage,
        )..where((m) => m.id.equals(1))).getSingle();

        final List<Product> products = actualRes.products != null
            ? (jsonDecode(actualRes.products!) as List)
                  .map((e) => Product.fromJson(e as Map<String, dynamic>))
                  .toList()
            : [];

        expect(products.length, equals(1));
        expect(
          products[0],
          equals(
            Product(
              sku: '123',
              name: 'Test',
              price: 300,
              unitName: 'box',
            ),
          ),
        );
      },
      tags: ['integration'],
    );

    test(
      'should return a format exception when the messages does not contain an id in replace message',
      () async {
        ChatMessage message = ChatMessage.product(
          role: MessageRole.user,
          timestamp: clock.now(),
        );

        final updateRes = await chatRepository.replaceChatMessage(message);
        expect(
          updateRes,
          isA<Error<bool>>().having(
            (s) => s.error,
            'error',
            isA<FormatException>(),
          ),
        );
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

    test(
      'should return an error when the message repository fails while replacing a message',
      () async {
        ChatMessage message = ChatMessage.product(
          id: 3,
          role: MessageRole.user,
          timestamp: clock.now(),
          products: [
            Product(
              sku: '123',
              name: '123',
              price: 30.0,
              unitName: 'box',
            ),
          ],
        );

        when(
          () => databaseService
              .update(databaseService.chatMessage)
              .replace(any()),
        ).thenThrow(Exception('test'));

        final updateRes = await chatRepository.replaceChatMessage(message);
        expect(
          updateRes,
          isA<Error<bool>>().having((s) => s.error, 'error', isA<Exception>()),
        );
      },
    );
  });
}
