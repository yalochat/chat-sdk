// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:yalo_chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:yalo_chat_flutter_sdk/domain/models/command/chat_command.dart';
import 'package:yalo_chat_flutter_sdk/domain/models/product/product.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository_websocket.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service_websocket.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/cta_button.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;

class MockYaloChatClient extends Mock implements YaloChatClient {}

class MockYaloMessageService extends Mock implements YaloMessageService {}

class MockYaloMessageServiceWebSocket extends Mock
    implements YaloMessageServiceWebSocket {}

class MockYaloMediaService extends Mock implements YaloMediaService {}

void main() {
  group(YaloMessageRepositoryWebSocket, () {
    late MockYaloChatClient mockClient;
    late MockYaloMessageService mockMessageService;
    late MockYaloMessageServiceWebSocket mockWebSocketService;
    late MockYaloMediaService mockMediaService;
    late YaloMessageRepositoryWebSocket repo;
    late StreamController<proto.PollMessageItem> incoming;

    const fixedDate = '2024-01-01T00:00:00.000Z';
    late Directory tempDir;

    final assistantTextStub = proto.PollMessageItem(
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
      status: 'IN_DELIVERY',
    );

    final assistantImageStub = proto.PollMessageItem(
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

    final assistantButtonsStub = proto.PollMessageItem(
      id: 'btn-1',
      message: proto.SdkMessage(
        buttonsMessageRequest: proto.ButtonsMessageRequest(
          content: proto.ButtonsMessage(
            header: 'Header text',
            body: 'Choose an option',
            footer: 'Footer text',
            buttons: ['Yes', 'No'],
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final assistantCtaStub = proto.PollMessageItem(
      id: 'cta-1',
      message: proto.SdkMessage(
        ctaMessageRequest: proto.CTAMessageRequest(
          content: proto.CTAMessage(
            body: 'Visit our site',
            buttons: [proto.CTAButton(text: 'Open', url: 'https://e.com')],
          ),
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final assistantProductStub = proto.PollMessageItem(
      id: 'prod-1',
      message: proto.SdkMessage(
        productMessageRequest: proto.ProductMessageRequest(
          orientation:
              proto.ProductMessageRequest_Orientation.ORIENTATION_VERTICAL,
          products: [
            proto.Product(
              sku: 'sku-1',
              name: 'Apples',
              price: 2.5,
              unitStep: 1,
              unitName: 'box',
            ),
          ],
        ),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final assistantCarouselStub = proto.PollMessageItem(
      id: 'carousel-1',
      message: proto.SdkMessage(
        productMessageRequest: proto.ProductMessageRequest(
          orientation:
              proto.ProductMessageRequest_Orientation.ORIENTATION_HORIZONTAL,
          products: [
            proto.Product(
              sku: 'sku-2',
              name: 'Oranges',
              price: 3.0,
              unitStep: 1,
              unitName: 'bag',
            ),
          ],
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
      tempDir = Directory.systemTemp.createTempSync('yalo_ws_test_');
      mockClient = MockYaloChatClient();
      mockMessageService = MockYaloMessageService();
      mockWebSocketService = MockYaloMessageServiceWebSocket();
      mockMediaService = MockYaloMediaService();
      incoming = StreamController<proto.PollMessageItem>.broadcast();

      when(() => mockWebSocketService.messages())
          .thenAnswer((_) => incoming.stream);

      repo = YaloMessageRepositoryWebSocket(
        yaloChatClient: mockClient,
        websocketService: mockWebSocketService,
        messageService: mockMessageService,
        mediaService: mockMediaService,
        directory: () async => tempDir,
      );
    });

    tearDown(() async {
      repo.dispose();
      await incoming.close();
      tempDir.deleteSync(recursive: true);
    });

    group('messages', () {
      test('returns a broadcast stream', () {
        expect(repo.messages().isBroadcast, isTrue);
      });

      test('emits translated text messages from websocket frames', () async {
        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantTextStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(
          received.single,
          isA<ChatMessage>()
              .having((m) => m.content, 'content', 'Hello')
              .having((m) => m.wiId, 'wiId', 'msg-1')
              .having((m) => m.role, 'role', MessageRole.assistant)
              .having((m) => m.type, 'type', MessageType.text),
        );
      });

      test('subscribes to the websocket service only once across calls',
          () async {
        repo.messages().listen((_) {});
        repo.messages().listen((_) {});
        await Future.delayed(Duration.zero);

        verify(() => mockWebSocketService.messages()).called(1);
      });

      test('caches wiId after emission to suppress duplicates', () async {
        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantTextStub);
        incoming.add(assistantTextStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(repo.cache.get('msg-1'), isTrue);
      });

      test('emits TypingStop on the events stream when a message arrives',
          () async {
        final eventFuture = repo.events().first;
        repo.messages().listen((_) {});

        incoming.add(assistantTextStub);
        final event = await eventFuture;

        expect(event, isA<TypingStop>());
      });

      test('downloads image and emits message with local fileName', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        when(() => mockMediaService.downloadMedia(any()))
            .thenAnswer((_) async => Result.ok(imageBytes));

        final messageFuture = repo.messages().first;
        incoming.add(assistantImageStub);
        final message = await messageFuture;

        expect(
          message,
          isA<ChatMessage>()
              .having((m) => m.type, 'type', MessageType.image)
              .having((m) => m.byteCount, 'byteCount', 3)
              .having((m) => m.mediaType, 'mediaType', 'image/jpeg'),
        );
        expect(message.fileName, isNot(contains('http')));
        expect(File(message.fileName!).existsSync(), isTrue);
      });

      test('does not emit image message when download fails', () async {
        final downloadCompleter = Completer<Result<Uint8List>>();
        when(() => mockMediaService.downloadMedia(any()))
            .thenAnswer((_) => downloadCompleter.future);

        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantImageStub);
        downloadCompleter.complete(Result.error(Exception('network error')));
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        expect(received, isEmpty);
      });

      test('emits a buttons message translated from buttonsMessageRequest',
          () async {
        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantButtonsStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(
          received.single,
          isA<ChatMessage>()
              .having((m) => m.type, 'type', MessageType.buttons)
              .having((m) => m.content, 'content', 'Choose an option')
              .having((m) => m.header, 'header', 'Header text')
              .having((m) => m.footer, 'footer', 'Footer text')
              .having((m) => m.buttons, 'buttons', ['Yes', 'No']),
        );
      });

      test('emits a cta message translated from ctaMessageRequest', () async {
        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantCtaStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(received.single.type, equals(MessageType.cta));
        expect(
          received.single.ctaButtons,
          equals([const CTAButton(text: 'Open', url: 'https://e.com')]),
        );
      });

      test('emits a product message with vertical orientation', () async {
        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantProductStub);
        await Future.delayed(Duration.zero);

        expect(received.single.type, equals(MessageType.product));
        expect(received.single.products, hasLength(1));
        expect(
          received.single.products.first,
          equals(const Product(
            sku: 'sku-1',
            name: 'Apples',
            price: 2.5,
            subunits: 0,
            unitStep: 1,
            unitName: 'box',
            subunitStep: 0,
          )),
        );
      });

      test('emits a carousel message with horizontal orientation', () async {
        final received = <ChatMessage>[];
        repo.messages().listen(received.add);

        incoming.add(assistantCarouselStub);
        await Future.delayed(Duration.zero);

        expect(received.single.type, equals(MessageType.productCarousel));
        expect(received.single.products.first.sku, equals('sku-2'));
      });

      test('emits TypingStop when the websocket stream errors', () async {
        final eventFuture = repo.events().first;
        repo.messages().listen((_) {}, onError: (_) {});

        incoming.addError(Exception('boom'));
        final event = await eventFuture;

        expect(event, isA<TypingStop>());
      });
    });

    group('events', () {
      test('returns a broadcast stream', () {
        expect(repo.events().isBroadcast, isTrue);
      });
    });

    group('sendMessage', () {
      final textMessage = ChatMessage.text(
        role: MessageRole.user,
        timestamp: DateTime.utc(2024),
        content: 'Hello',
      );

      test('emits TypingStart on the events stream before sending', () async {
        when(() => mockWebSocketService.sendSdkMessage(any()))
            .thenAnswer((_) async => Result.ok(Unit()));

        final eventFuture = repo.events().first;
        await repo.sendMessage(textMessage);

        final event = await eventFuture;
        expect(event, isA<TypingStart>());
        expect((event as TypingStart).statusText, equals('Writing message...'));
      });

      test('delegates text messages to websocketService.sendSdkMessage',
          () async {
        when(() => mockWebSocketService.sendSdkMessage(any()))
            .thenAnswer((_) async => Result.ok(Unit()));

        final result = await repo.sendMessage(textMessage);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockWebSocketService.sendSdkMessage(any())).called(1);
      });

      test('returns Result.error when the websocket service fails', () async {
        when(() => mockWebSocketService.sendSdkMessage(any()))
            .thenAnswer((_) async => Result.error(Exception('send failed')));

        final result = await repo.sendMessage(textMessage);

        expect(result, isA<Error<Unit>>());
      });

      test('uploads media and delegates for image messages', () async {
        when(() => mockMediaService.uploadMedia(any()))
            .thenAnswer((_) async => Result.ok(_makeUploadResponse()));
        when(() => mockWebSocketService.sendSdkMessage(any()))
            .thenAnswer((_) async => Result.ok(Unit()));

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
        verify(() => mockWebSocketService.sendSdkMessage(any())).called(1);
      });

      test('uploads media and delegates for voice messages', () async {
        when(() => mockMediaService.uploadMedia(any()))
            .thenAnswer((_) async => Result.ok(_makeUploadResponse()));
        when(() => mockWebSocketService.sendSdkMessage(any()))
            .thenAnswer((_) async => Result.ok(Unit()));

        final voiceMessage = ChatMessage.voice(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.wav',
          amplitudes: const [-10.0, 0.0],
          duration: 3,
          byteCount: 0,
          mediaType: 'audio/wav',
        );

        final result = await repo.sendMessage(voiceMessage);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMediaService.uploadMedia(any())).called(1);
        verify(() => mockWebSocketService.sendSdkMessage(any())).called(1);
      });

      test('uploads media and delegates for video messages', () async {
        when(() => mockMediaService.uploadMedia(any()))
            .thenAnswer((_) async => Result.ok(_makeUploadResponse()));
        when(() => mockWebSocketService.sendSdkMessage(any()))
            .thenAnswer((_) async => Result.ok(Unit()));

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
        verify(() => mockWebSocketService.sendSdkMessage(any())).called(1);
      });

      test('returns Error and skips send when media upload fails', () async {
        when(() => mockMediaService.uploadMedia(any()))
            .thenAnswer((_) async => Result.error(Exception('upload failed')));

        final imageMessage = ChatMessage.image(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
          fileName: 'test.jpg',
          byteCount: 0,
          mediaType: 'image/jpeg',
        );

        final result = await repo.sendMessage(imageMessage);

        expect(result, isA<Error<Unit>>());
        verifyNever(() => mockWebSocketService.sendSdkMessage(any()));
      });

      test('returns Error for unsupported message types', () async {
        final productMessage = ChatMessage.product(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
        );

        final result = await repo.sendMessage(productMessage);

        expect(result, isA<Error<Unit>>());
        verifyNever(() => mockWebSocketService.sendSdkMessage(any()));
      });
    });

    group('addToCart', () {
      test('calls registered command callback instead of service', () async {
        Object? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.addToCart: (payload) => receivedPayload = payload,
        });

        final result = await repo.addToCart('sku-1', 3);

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'sku': 'sku-1', 'quantity': 3.0}));
        verifyNever(() => mockMessageService.addToCart(any(), any()));
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(() => mockMessageService.addToCart(any(), any()))
            .thenAnswer((_) async => Result.ok(Unit()));

        final result = await repo.addToCart('sku-1', 3);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMessageService.addToCart('sku-1', 3)).called(1);
      });
    });

    group('removeFromCart', () {
      test('calls registered command callback with quantity', () async {
        Object? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.removeFromCart: (payload) => receivedPayload = payload,
        });

        final result = await repo.removeFromCart('sku-2', quantity: 1);

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'sku': 'sku-2', 'quantity': 1.0}));
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(() => mockMessageService.removeFromCart(any(),
                quantity: any(named: 'quantity')))
            .thenAnswer((_) async => Result.ok(Unit()));

        final result = await repo.removeFromCart('sku-2', quantity: 2);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMessageService.removeFromCart('sku-2', quantity: 2))
            .called(1);
      });
    });

    group('clearCart', () {
      test('calls registered command callback', () async {
        Object? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.clearCart: (payload) => receivedPayload = payload,
        });

        final result = await repo.clearCart();

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, isNull);
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(() => mockMessageService.clearCart())
            .thenAnswer((_) async => Result.ok(Unit()));

        final result = await repo.clearCart();

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMessageService.clearCart()).called(1);
      });
    });

    group('addPromotion', () {
      test('calls registered command callback', () async {
        Object? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.addPromotion: (payload) => receivedPayload = payload,
        });

        final result = await repo.addPromotion('promo-abc');

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'promotionId': 'promo-abc'}));
      });

      test('falls back to service when no command is registered', () async {
        when(() => mockClient.commands).thenReturn({});
        when(() => mockMessageService.addPromotion(any()))
            .thenAnswer((_) async => Result.ok(Unit()));

        final result = await repo.addPromotion('promo-abc');

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMessageService.addPromotion('promo-abc')).called(1);
      });
    });

    group('pause/resume', () {
      test('pause cancels the active subscription', () async {
        repo.messages().listen((_) {});
        await Future.delayed(Duration.zero);

        repo.pause();

        final received = <ChatMessage>[];
        repo.messages().listen(received.add);
        incoming.add(assistantTextStub);
        await Future.delayed(Duration.zero);

        expect(received, isEmpty);
      });

      test('resume restarts the subscription after pause', () async {
        repo.messages().listen((_) {});
        await Future.delayed(Duration.zero);

        repo.pause();
        repo.resume();

        final received = <ChatMessage>[];
        repo.messages().listen(received.add);
        incoming.add(assistantTextStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
      });

      test('resume is a no-op when not paused', () async {
        repo.resume();
        await Future.delayed(Duration.zero);

        verifyNever(() => mockWebSocketService.messages());
      });
    });

    group('dispose', () {
      test('closes the messages and events streams', () async {
        final messages = repo.messages();
        final events = repo.events();

        repo.dispose();
        await Future.delayed(Duration.zero);

        expect(await messages.isEmpty, isTrue);
        expect(await events.isEmpty, isTrue);
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
