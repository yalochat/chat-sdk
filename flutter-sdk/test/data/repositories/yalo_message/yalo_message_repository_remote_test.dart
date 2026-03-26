// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository_remote.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

class MockYaloChatClient extends Mock implements YaloChatClient {}

class MockYaloMessageService extends Mock implements YaloMessageService {}

void main() {
  group(YaloMessageRepositoryRemote, () {
    late MockYaloChatClient mockClient;
    late MockYaloMessageService mockMessageService;
    late YaloMessageRepositoryRemote repo;

    const fixedDate = '2024-01-01T00:00:00.000Z';

    final assistantResponseStub = proto.PollMessageItem(
      id: 'msg-1',
      message: proto.SdkMessage(
        textMessageRequest: proto.TextMessageRequest(
          content: proto.TextMessage(
            text: 'Hello',
            role: proto.MessageRole.MESSAGE_ROLE_AGENT,
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: "IN_DELIVERY",
    );

    setUpAll(() {
      registerFallbackValue(proto.SdkMessage());
    });

    setUp(() {
      mockClient = MockYaloChatClient();
      mockMessageService = MockYaloMessageService();
      repo = YaloMessageRepositoryRemote(
        yaloChatClient: mockClient,
        messageService: mockMessageService,
      );
    });

    tearDown(() {
      repo.dispose();
    });

    group('events', () {
      test('returns a broadcast stream', () {
        expect(repo.events().isBroadcast, isTrue);
      });
    });

    group('messages', () {
      test('returns a broadcast stream', () {
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([]));

        expect(repo.messages().isBroadcast, isTrue);
      });

      test('emits translated messages received from fetchMessages', () async {
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([assistantResponseStub]));

        final message = await repo.messages().first;
        repo.dispose();

        expect(message.content, equals('Hello'));
        expect(message.wiId, equals('msg-1'));
        expect(message.role, equals(MessageRole.assistant));
      });

      test(
        'does not emit messages when fetchMessages returns an empty list',
        () async {
          final fetchCompleter = Completer<void>();
          when(() => mockMessageService.fetchMessages(any())).thenAnswer((
            _,
          ) async {
            if (!fetchCompleter.isCompleted) fetchCompleter.complete();
            return Result.ok([]);
          });

          final received = <ChatMessage>[];
          repo.messages().listen(received.add);

          await fetchCompleter.future;
          await Future.delayed(Duration.zero);

          expect(received, isEmpty);
        },
      );

      test(
        'filters duplicate messages with the same wiId within a single poll batch',
        () async {
          when(() => mockMessageService.fetchMessages(any())).thenAnswer(
            (_) async =>
                Result.ok([assistantResponseStub, assistantResponseStub]),
          );

          final received = <ChatMessage>[];
          final completer = Completer<void>();

          repo.messages().listen((msg) {
            received.add(msg);
            if (!completer.isCompleted) completer.complete();
          });

          await completer.future;
          await Future.delayed(Duration.zero);
          repo.dispose();

          expect(received, hasLength(1));
        },
      );

      test(
        'caches the wiId after first emission to prevent re-emission in future polls',
        () async {
          when(
            () => mockMessageService.fetchMessages(any()),
          ).thenAnswer((_) async => Result.ok([assistantResponseStub]));

          await repo.messages().first;
          repo.dispose();

          expect(repo.cache.get('msg-1'), equals(true));
        },
      );

      test(
        'emits TypingStop to the events stream when messages are received',
        () async {
          when(
            () => mockMessageService.fetchMessages(any()),
          ).thenAnswer((_) async => Result.ok([assistantResponseStub]));

          final eventFuture = repo.events().first;
          repo.messages().listen((_) {});

          final event = await eventFuture;
          repo.dispose();

          expect(event, isA<TypingStop>());
        },
      );

      test(
        'emits TypingStop to the events stream when fetchMessages fails',
        () async {
          when(
            () => mockMessageService.fetchMessages(any()),
          ).thenAnswer((_) async => Result.error(Exception('Network error')));

          final eventFuture = repo.events().first;
          repo.messages().listen((_) {});

          final event = await eventFuture;
          repo.dispose();

          expect(event, isA<TypingStop>());
        },
      );
    });

    group('sendMessage', () {
      ChatMessage textMessage = ChatMessage.text(
        role: MessageRole.user,
        timestamp: DateTime.utc(2024),
        content: 'Hello',
      );

      test('emits TypingStart to the events stream before sending', () async {
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final eventFuture = repo.events().first;
        await repo.sendMessage(textMessage);

        final event = await eventFuture;

        expect(event, isA<TypingStart>());
        expect((event as TypingStart).statusText, equals('Writing message...'));
      });

      test('returns Result.ok when the client succeeds', () async {
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final result = await repo.sendMessage(textMessage);

        expect(result, isA<Ok<Unit>>());
      });

      test('returns Result.error when the client fails', () async {
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.error(Exception('Send failed')));

        final result = await repo.sendMessage(textMessage);

        expect(result, isA<Error<Unit>>());
      });

      test(
        'delegates to yaloChatClient.sendSdkMessage for text messages',
        () async {
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          await repo.sendMessage(textMessage);

          verify(() => mockMessageService.sendSdkMessage(any())).called(1);
        },
      );

      test(
        'returns Result.error(FormatException) for voice messages without calling the client',
        () async {
          ChatMessage voiceMessage = ChatMessage.voice(
            role: MessageRole.user,
            timestamp: DateTime.utc(2024),
            fileName: 'test.wav',
            amplitudes: [-10.0, 0.0, -10.0],
            duration: 3,
          );

          final result = await repo.sendMessage(voiceMessage);

          expect(result, isA<Error<Unit>>());
          expect((result as Error<Unit>).error, isA<FormatException>());
          verifyNever(() => mockMessageService.sendSdkMessage(any()));
        },
      );

      test(
        'returns Result.error(FormatException) for image messages without calling the client',
        () async {
          ChatMessage imageMessage = ChatMessage.image(
            role: MessageRole.user,
            timestamp: DateTime.utc(2024),
            fileName: 'test.jpg',
          );

          final result = await repo.sendMessage(imageMessage);

          expect(result, isA<Error<Unit>>());
          expect((result as Error<Unit>).error, isA<FormatException>());
          verifyNever(() => mockMessageService.sendSdkMessage(any()));
        },
      );
    });

    group('dispose', () {
      test('sets polling to false', () {
        repo.polling = true;
        repo.dispose();
        expect(repo.polling, isFalse);
      });
    });

    group('executeActions', () {
      test('calls all registered actions', () async {
        bool firstCalled = false;
        bool secondCalled = false;

        when(() => mockClient.actions).thenReturn([
          Action(name: 'first', action: () => firstCalled = true),
          Action(name: 'second', action: () => secondCalled = true),
        ]);

        await repo.executeActions();

        expect(firstCalled, isTrue);
        expect(secondCalled, isTrue);
      });

      test('does nothing when no actions are registered', () {
        when(() => mockClient.actions).thenReturn([]);

        expect(() async => repo.executeActions(), returnsNormally);
      });
    });
  });
}
