// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/domain/models/command/chat_command.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository_remote.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:cross_file/cross_file.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/cta_button.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

class MockYaloChatClient extends Mock implements YaloChatClient {}

class MockYaloMessageService extends Mock implements YaloMessageService {}

class MockYaloMediaService extends Mock implements YaloMediaService {}

void main() {
  group(YaloMessageRepositoryRemote, () {
    late MockYaloChatClient mockClient;
    late MockYaloMessageService mockMessageService;
    late MockYaloMediaService mockMediaService;
    late YaloMessageRepositoryRemote repo;

    const fixedDate = '2024-01-01T00:00:00.000Z';
    late Directory tempDir;

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

    final assistantImageResponseStub = proto.PollMessageItem(
      id: 'img-1',
      message: proto.SdkMessage(
        imageMessageRequest: proto.ImageMessageRequest(
          content: proto.ImageMessage(
            mediaUrl: 'https://example.com/image.jpg',
            text: 'Caption',
            mediaType: 'image/jpeg',
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final assistantButtonsResponseStub = proto.PollMessageItem(
      id: 'btn-1',
      message: proto.SdkMessage(
        buttonsMessageRequest: proto.ButtonsMessageRequest(
          content: proto.ButtonsMessage(
            header: 'Header text',
            body: 'Choose an option',
            footer: 'Footer text',
            buttons: ['Yes', 'No', 'Maybe'],
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final assistantCtaResponseStub = proto.PollMessageItem(
      id: 'cta-1',
      message: proto.SdkMessage(
        ctaMessageRequest: proto.CTAMessageRequest(
          content: proto.CTAMessage(
            header: 'CTA header',
            body: 'Visit our site',
            footer: 'CTA footer',
            buttons: [
              proto.CTAButton(text: 'Open', url: 'https://example.com'),
              proto.CTAButton(text: 'Docs', url: 'https://example.com/docs'),
            ],
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final assistantVideoResponseStub = proto.PollMessageItem(
      id: 'vid-1',
      message: proto.SdkMessage(
        videoMessageRequest: proto.VideoMessageRequest(
          content: proto.VideoMessage(
            mediaUrl: 'https://example.com/video.mp4',
            text: 'Video caption',
            mediaType: 'video/mp4',
            duration: 15.0,
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    setUpAll(() {
      registerFallbackValue(proto.SdkMessage());
      registerFallbackValue(XFile(''));
    });

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('yalo_test_');
      mockClient = MockYaloChatClient();
      mockMessageService = MockYaloMessageService();
      mockMediaService = MockYaloMediaService();
      repo = YaloMessageRepositoryRemote(
        yaloChatClient: mockClient,
        messageService: mockMessageService,
        mediaService: mockMediaService,
        directory: () async => tempDir,
      );
    });

    tearDownAll(() {
      tempDir.deleteSync(recursive: true);
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
        'downloads image and emits message with local fileName',
        () async {
          final imageBytes = Uint8List.fromList([1, 2, 3]);
          when(
            () => mockMessageService.fetchMessages(any()),
          ).thenAnswer((_) async => Result.ok([assistantImageResponseStub]));
          when(
            () => mockMediaService.downloadMedia(any()),
          ).thenAnswer((_) async => Result.ok(imageBytes));

          final message = await repo.messages().first;
          repo.dispose();

          expect(message.wiId, equals('img-1'));
          expect(message.type, equals(MessageType.image));
          expect(message.byteCount, equals(3));
          expect(message.mediaType, equals('image/jpeg'));
          expect(message.fileName, isNot(contains('http')));
          expect(File(message.fileName!).existsSync(), isTrue);
        },
      );

      test(
        'does not emit image message when download fails',
        () async {
          final fetchCompleter = Completer<void>();
          when(() => mockMessageService.fetchMessages(any())).thenAnswer((_) async {
            if (!fetchCompleter.isCompleted) fetchCompleter.complete();
            return Result.ok([assistantImageResponseStub]);
          });
          when(
            () => mockMediaService.downloadMedia(any()),
          ).thenAnswer((_) async => Result.error(Exception('network error')));

          final received = <ChatMessage>[];
          repo.messages().listen(received.add);

          await fetchCompleter.future;
          await Future.delayed(Duration.zero);
          repo.dispose();

          expect(received, isEmpty);
        },
      );

      test(
        'downloads video and emits message with local fileName',
        () async {
          final videoBytes = Uint8List.fromList([0, 0, 0, 1, 2, 3]);
          when(
            () => mockMessageService.fetchMessages(any()),
          ).thenAnswer((_) async => Result.ok([assistantVideoResponseStub]));
          when(
            () => mockMediaService.downloadMedia(any()),
          ).thenAnswer((_) async => Result.ok(videoBytes));

          final message = await repo.messages().first;
          repo.dispose();

          expect(message.wiId, equals('vid-1'));
          expect(message.type, equals(MessageType.video));
          expect(message.content, equals('Video caption'));
          expect(message.duration, equals(15));
          expect(message.byteCount, equals(6));
          expect(message.mediaType, equals('video/mp4'));
          expect(message.fileName, isNot(contains('http')));
          expect(File(message.fileName!).existsSync(), isTrue);
        },
      );

      test(
        'does not emit video message when download fails',
        () async {
          final fetchCompleter = Completer<void>();
          when(() => mockMessageService.fetchMessages(any())).thenAnswer((_) async {
            if (!fetchCompleter.isCompleted) fetchCompleter.complete();
            return Result.ok([assistantVideoResponseStub]);
          });
          when(
            () => mockMediaService.downloadMedia(any()),
          ).thenAnswer((_) async => Result.error(Exception('network error')));

          final received = <ChatMessage>[];
          repo.messages().listen(received.add);

          await fetchCompleter.future;
          await Future.delayed(Duration.zero);
          repo.dispose();

          expect(received, isEmpty);
        },
      );

      test('emits a buttons message translated from buttonsMessageRequest', () async {
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([assistantButtonsResponseStub]));

        final message = await repo.messages().first;
        repo.dispose();

        expect(message.wiId, equals('btn-1'));
        expect(message.type, equals(MessageType.buttons));
        expect(message.role, equals(MessageRole.assistant));
        expect(message.content, equals('Choose an option'));
        expect(message.header, equals('Header text'));
        expect(message.footer, equals('Footer text'));
        expect(message.buttons, equals(['Yes', 'No', 'Maybe']));
        expect(message.ctaButtons, isEmpty);
      });

      test('emits a buttons message with null header/footer when not set', () async {
        final stub = proto.PollMessageItem(
          id: 'btn-2',
          message: proto.SdkMessage(
            buttonsMessageRequest: proto.ButtonsMessageRequest(
              content: proto.ButtonsMessage(
                body: 'Pick one',
                buttons: ['A'],
              ),
            ),
          ),
          date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
          userId: 'user-123',
          status: 'IN_DELIVERY',
        );
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([stub]));

        final message = await repo.messages().first;
        repo.dispose();

        expect(message.type, equals(MessageType.buttons));
        expect(message.header, isNull);
        expect(message.footer, isNull);
        expect(message.buttons, equals(['A']));
      });

      test('emits a cta message translated from ctaMessageRequest', () async {
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([assistantCtaResponseStub]));

        final message = await repo.messages().first;
        repo.dispose();

        expect(message.wiId, equals('cta-1'));
        expect(message.type, equals(MessageType.cta));
        expect(message.role, equals(MessageRole.assistant));
        expect(message.content, equals('Visit our site'));
        expect(message.header, equals('CTA header'));
        expect(message.footer, equals('CTA footer'));
        expect(message.buttons, isEmpty);
        expect(
          message.ctaButtons,
          equals([
            const CTAButton(text: 'Open', url: 'https://example.com'),
            const CTAButton(text: 'Docs', url: 'https://example.com/docs'),
          ]),
        );
      });

      test('emits a cta message with null header/footer when not set', () async {
        final stub = proto.PollMessageItem(
          id: 'cta-2',
          message: proto.SdkMessage(
            ctaMessageRequest: proto.CTAMessageRequest(
              content: proto.CTAMessage(
                body: 'Body only',
                buttons: [proto.CTAButton(text: 'Go', url: 'https://e.com')],
              ),
            ),
          ),
          date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
          userId: 'user-123',
          status: 'IN_DELIVERY',
        );
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([stub]));

        final message = await repo.messages().first;
        repo.dispose();

        expect(message.type, equals(MessageType.cta));
        expect(message.header, isNull);
        expect(message.footer, isNull);
        expect(message.ctaButtons, hasLength(1));
        expect(message.ctaButtons.first.text, equals('Go'));
        expect(message.ctaButtons.first.url, equals('https://e.com'));
      });

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

      test('uploads and delegates to messageService.sendSdkMessage for voice messages', () async {
        when(
          () => mockMediaService.uploadMedia(any()),
        ).thenAnswer((_) async => Result.ok(_makeUploadResponse()));
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final voiceMessage = ChatMessage.voice(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.wav',
          amplitudes: [-10.0, 0.0, -10.0],
          duration: 3,
          byteCount: 0,
          mediaType: 'audio/wav',
        );

        final result = await repo.sendMessage(voiceMessage);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMediaService.uploadMedia(any())).called(1);
        verify(() => mockMessageService.sendSdkMessage(any())).called(1);
      });

      test('uploads and delegates to messageService.sendSdkMessage for image messages', () async {
        when(
          () => mockMediaService.uploadMedia(any()),
        ).thenAnswer((_) async => Result.ok(_makeUploadResponse()));
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final imageMessage = ChatMessage.image(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.jpg',
          byteCount: 0,
          mediaType: 'image/jpeg',
        );

        final result = await repo.sendMessage(imageMessage);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMediaService.uploadMedia(any())).called(1);
        verify(() => mockMessageService.sendSdkMessage(any())).called(1);
      });

      test('uploads and delegates to messageService.sendSdkMessage for video messages', () async {
        when(
          () => mockMediaService.uploadMedia(any()),
        ).thenAnswer((_) async => Result.ok(_makeUploadResponse()));
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final videoMessage = ChatMessage.video(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.mp4',
          duration: 10,
          byteCount: 1024,
          mediaType: 'video/mp4',
        );

        final result = await repo.sendMessage(videoMessage);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMediaService.uploadMedia(any())).called(1);
        verify(() => mockMessageService.sendSdkMessage(any())).called(1);
      });

      test('returns Error without calling sendSdkMessage when video upload fails', () async {
        when(
          () => mockMediaService.uploadMedia(any()),
        ).thenAnswer((_) async => Result.error(Exception('upload failed')));

        final videoMessage = ChatMessage.video(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.mp4',
          duration: 10,
          byteCount: 1024,
          mediaType: 'video/mp4',
        );

        final result = await repo.sendMessage(videoMessage);

        expect(result, isA<Error<Unit>>());
        verifyNever(() => mockMessageService.sendSdkMessage(any()));
      });

      test('returns Error without calling sendSdkMessage when upload fails', () async {
        when(
          () => mockMediaService.uploadMedia(any()),
        ).thenAnswer((_) async => Result.error(Exception('upload failed')));

        final imageMessage = ChatMessage.image(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.jpg',
          byteCount: 0,
          mediaType: 'image/jpeg',
        );

        final result = await repo.sendMessage(imageMessage);

        expect(result, isA<Error<Unit>>());
        verifyNever(() => mockMessageService.sendSdkMessage(any()));
      });
    });

    group('dispose', () {
      test('sets polling to false', () {
        repo.polling = true;
        repo.dispose();
        expect(repo.polling, isFalse);
      });
    });

    group('pause/resume', () {
      test('pause stops polling', () {
        repo.polling = true;
        repo.pause();
        expect(repo.polling, isFalse);
      });

      test('resume restarts polling after pause', () async {
        when(
          () => mockMessageService.fetchMessages(any()),
        ).thenAnswer((_) async => Result.ok([]));

        repo.messages(); // start polling
        repo.pause();
        expect(repo.polling, isFalse);

        repo.resume();
        expect(repo.polling, isTrue);
      });

      test('resume does nothing when not paused', () {
        repo.polling = false;
        repo.resume(); // should not start polling
        expect(repo.polling, isFalse);
      });
    });

    group('addToCart', () {
      test('calls registered command callback instead of service', () async {
        dynamic receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.addToCart: (payload) => receivedPayload = payload,
        });

        final Result<Unit> result = await repo.addToCart('sku-1', 3);

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'sku': 'sku-1', 'quantity': 3.0}));
        verifyNever(() => mockMessageService.addToCart(any(), any()));
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(
          () => mockMessageService.addToCart(any(), any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final Result<Unit> result = await repo.addToCart('sku-1', 3);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMessageService.addToCart('sku-1', 3)).called(1);
      });
    });

    group('removeFromCart', () {
      test('calls registered command callback with quantity', () async {
        dynamic receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.removeFromCart: (payload) => receivedPayload = payload,
        });

        final Result<Unit> result =
            await repo.removeFromCart('sku-2', quantity: 1);

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'sku': 'sku-2', 'quantity': 1.0}));
      });

      test('calls registered command callback without quantity', () async {
        dynamic receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.removeFromCart: (payload) => receivedPayload = payload,
        });

        final Result<Unit> result = await repo.removeFromCart('sku-2');

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'sku': 'sku-2', 'quantity': null}));
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(
          () => mockMessageService.removeFromCart(
            any(),
            quantity: any(named: 'quantity'),
          ),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final Result<Unit> result =
            await repo.removeFromCart('sku-2', quantity: 2);

        expect(result, isA<Ok<Unit>>());
        verify(
          () => mockMessageService.removeFromCart('sku-2', quantity: 2),
        ).called(1);
      });
    });

    group('clearCart', () {
      test('calls registered command callback', () async {
        dynamic receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.clearCart: (payload) => receivedPayload = payload,
        });

        final Result<Unit> result = await repo.clearCart();

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, isNull);
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(
          () => mockMessageService.clearCart(),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final Result<Unit> result = await repo.clearCart();

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMessageService.clearCart()).called(1);
      });
    });

    group('addPromotion', () {
      test('calls registered command callback', () async {
        dynamic receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.addPromotion: (payload) => receivedPayload = payload,
        });

        final Result<Unit> result = await repo.addPromotion('promo-abc');

        expect(result, isA<Ok<Unit>>());
        expect(
          receivedPayload,
          equals({'promotionId': 'promo-abc'}),
        );
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(
          () => mockMessageService.addPromotion(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        final Result<Unit> result = await repo.addPromotion('promo-abc');

        expect(result, isA<Ok<Unit>>());
        verify(
          () => mockMessageService.addPromotion('promo-abc'),
        ).called(1);
      });
    });
  });
}

MediaUploadResponse _makeUploadResponse() => MediaUploadResponse(
  id: 'media-1',
  signedUrl: 'https://example.com/signed-url',
  originalName: 'test.jpg',
  type: 'image/jpeg',
  metadata: {},
  createdAt: DateTime.utc(2024),
  expiresAt: DateTime.utc(2024, 1, 2),
);
