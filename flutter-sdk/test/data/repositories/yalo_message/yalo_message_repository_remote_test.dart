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
import 'package:yalo_chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository_remote.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart'
    as proto;

class MockYaloChatClient extends Mock implements YaloChatClient {}

class MockYaloMessageService extends Mock implements YaloMessageService {}

class MockYaloMediaService extends Mock implements YaloMediaService {}

void main() {
  group(YaloMessageRepositoryRemote, () {
    late MockYaloChatClient mockClient;
    late MockYaloMessageService mockMessageService;
    late MockYaloMediaService mockMediaService;
    late YaloMessageRepositoryRemote repo;
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

    final chatStatusStub = proto.PollMessageItem(
      id: 'status-1',
      message: proto.SdkMessage(
        chatStatusRequest: proto.ChatStatusRequest(status: 'Agent is typing'),
      ),
      date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
      userId: 'user-123',
      status: 'IN_DELIVERY',
    );

    final emptyChatStatusStub = proto.PollMessageItem(
      id: 'status-2',
      message: proto.SdkMessage(
        chatStatusRequest: proto.ChatStatusRequest(status: ''),
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

    final assistantProductConfirmationStub = proto.PollMessageItem(
      id: 'confirm-1',
      message: proto.SdkMessage(
        productConfirmationMessageRequest:
            proto.ProductConfirmationMessageRequest(
              sku: 'sku-9',
              header: 'Added to cart',
              body: 'You have 3 bags',
              footer: 'Continue shopping',
              units: 3,
              subunits: 0,
              button: proto.Button(
                text: 'Done',
                buttonType: proto.ButtonType.BUTTON_TYPE_POSTBACK,
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
      tempDir = Directory.systemTemp.createTempSync('yalo_remote_test_');
      mockClient = MockYaloChatClient();
      mockMessageService = MockYaloMessageService();
      mockMediaService = MockYaloMediaService();
      incoming = StreamController<proto.PollMessageItem>.broadcast();

      when(
        () => mockMessageService.messages(),
      ).thenAnswer((_) => incoming.stream);

      repo = YaloMessageRepositoryRemote(
        yaloChatClient: mockClient,
        messageService: mockMessageService,
        mediaService: mockMediaService,
        directory: () async => tempDir,
        chatStatusTimeout: const Duration(milliseconds: 50),
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

      test('emits translated text messages from the stream', () async {
        final received = <ChatMessage>[];
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);

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

      test('subscribes to the service only once across calls', () async {
        repo.messages().listen((_) {});
        repo.messages().listen((_) {});
        await Future.delayed(Duration.zero);

        verify(() => mockMessageService.messages()).called(1);
      });

      test('caches wiId after emission to suppress duplicates', () async {
        final received = <ChatMessage>[];
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);

        incoming.add(assistantTextStub);
        incoming.add(assistantTextStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
        expect(repo.cache.get('msg-1'), isTrue);
      });

      test(
        'emits a clearing chat status before delivering a message',
        () async {
          final firstFuture = repo.messages().first;
          incoming.add(assistantTextStub);
          final first = await firstFuture;

          expect(first.type, equals(MessageType.chatStatus));
          expect(first.content, isEmpty);
        },
      );

      test('downloads image and emits message with local fileName', () async {
        final imageBytes = Uint8List.fromList([1, 2, 3]);
        when(
          () => mockMediaService.downloadMedia(any()),
        ).thenAnswer((_) async => Result.ok(imageBytes));

        final messageFuture = repo.messages().firstWhere(
          (m) => m.type != MessageType.chatStatus,
        );
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
        when(
          () => mockMediaService.downloadMedia(any()),
        ).thenAnswer((_) => downloadCompleter.future);

        final received = <ChatMessage>[];
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);

        incoming.add(assistantImageStub);
        downloadCompleter.complete(Result.error(Exception('network error')));
        await Future.delayed(Duration.zero);
        await Future.delayed(Duration.zero);

        expect(received, isEmpty);
      });

      test('emits a product message with vertical orientation', () async {
        final received = <ChatMessage>[];
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);

        incoming.add(assistantProductStub);
        await Future.delayed(Duration.zero);

        expect(received.single.type, equals(MessageType.product));
        expect(received.single.products, hasLength(1));
        expect(
          received.single.products.first,
          equals(
            const Product(
              sku: 'sku-1',
              name: 'Apples',
              price: 2.5,
              subunits: 0,
              unitStep: 1,
              unitName: 'box',
              subunitStep: 0,
            ),
          ),
        );
      });

      test('emits a carousel message with horizontal orientation', () async {
        final received = <ChatMessage>[];
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);

        incoming.add(assistantCarouselStub);
        await Future.delayed(Duration.zero);

        expect(received.single.type, equals(MessageType.productCarousel));
        expect(received.single.products.first.sku, equals('sku-2'));
      });

      test('emits a product confirmation message', () async {
        final received = <ChatMessage>[];
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);

        incoming.add(assistantProductConfirmationStub);
        await Future.delayed(Duration.zero);

        expect(
          received.single,
          isA<ChatMessage>()
              .having((m) => m.type, 'type', MessageType.productConfirmation)
              .having((m) => m.header, 'header', 'Added to cart')
              .having((m) => m.content, 'content', 'You have 3 bags')
              .having((m) => m.footer, 'footer', 'Continue shopping'),
        );
        expect(received.single.buttons.single.text, equals('Done'));
        expect(received.single.products.single.sku, equals('sku-9'));
        expect(received.single.products.single.unitsAdded, equals(3));
      });

      test(
        'forwards ChatStatusRequest frames as a chat status message',
        () async {
          final messageFuture = repo.messages().first;
          incoming.add(chatStatusStub);
          final message = await messageFuture;

          expect(message.type, equals(MessageType.chatStatus));
          expect(message.content, equals('Agent is typing'));
        },
      );

      test(
        'forwards an empty ChatStatusRequest as a clearing chat status',
        () async {
          final messageFuture = repo.messages().first;
          incoming.add(emptyChatStatusStub);
          final message = await messageFuture;

          expect(message.type, equals(MessageType.chatStatus));
          expect(message.content, isEmpty);
        },
      );

      test(
        'emits a clearing chat status after the timeout when the backend goes silent',
        () async {
          final received = <ChatMessage>[];
          repo.messages().listen(received.add);

          incoming.add(chatStatusStub);
          await Future.delayed(const Duration(milliseconds: 80));

          expect(received, hasLength(2));
          expect(received.first.content, equals('Agent is typing'));
          expect(received.last.type, equals(MessageType.chatStatus));
          expect(received.last.content, isEmpty);
        },
      );

      test(
        'cancels the chat status timeout when a real message arrives',
        () async {
          final received = <ChatMessage>[];
          repo.messages().listen(received.add);

          incoming.add(chatStatusStub);
          await Future.delayed(const Duration(milliseconds: 10));
          incoming.add(assistantTextStub);
          await Future.delayed(const Duration(milliseconds: 80));

          final clearingStatuses = received.where(
            (m) => m.type == MessageType.chatStatus && m.content.isEmpty,
          );
          expect(clearingStatuses, hasLength(1));
        },
      );

      test(
        'emits a clearing chat status when the message stream errors',
        () async {
          final messageFuture = repo.messages().first;
          incoming.addError(Exception('boom'));
          final message = await messageFuture;

          expect(message.type, equals(MessageType.chatStatus));
          expect(message.content, isEmpty);
        },
      );
    });

    group('sendMessage', () {
      final textMessage = ChatMessage.text(
        role: MessageRole.user,
        timestamp: DateTime.utc(2024),
        content: 'Hello',
      );

      test(
        'delegates text messages to messageService.sendSdkMessage',
        () async {
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.sendMessage(textMessage);

          expect(result, isA<Ok<Unit>>());
          verify(() => mockMessageService.sendSdkMessage(any())).called(1);
        },
      );

      test('returns Result.error when the service fails', () async {
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.error(Exception('send failed')));

        final result = await repo.sendMessage(textMessage);

        expect(result, isA<Error<Unit>>());
      });

      test('uploads media and delegates for image messages', () async {
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

      test('uploads media and delegates for voice messages', () async {
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
          amplitudes: const [-10.0, 0.0],
          duration: 3,
          byteCount: 0,
          mediaType: 'audio/wav',
        );

        final result = await repo.sendMessage(voiceMessage);

        expect(result, isA<Ok<Unit>>());
        verify(() => mockMediaService.uploadMedia(any())).called(1);
        verify(() => mockMessageService.sendSdkMessage(any())).called(1);
      });

      test('uploads media and delegates for video messages', () async {
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

      test('returns Error and skips send when media upload fails', () async {
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

      test('returns Error for unsupported message types', () async {
        final productMessage = ChatMessage.product(
          role: MessageRole.user,
          timestamp: DateTime.utc(2024),
        );

        final result = await repo.sendMessage(productMessage);

        expect(result, isA<Error<Unit>>());
        verifyNever(() => mockMessageService.sendSdkMessage(any()));
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
        verifyNever(() => mockMessageService.sendSdkMessage(any()));
      });

      test(
        'sends an add to cart message when no command is registered',
        () async {
          when(() => mockClient.commands).thenReturn({});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.addToCart('sku-1', 3);

          expect(result, isA<Ok<Unit>>());
          final proto.SdkMessage sent =
              verify(
                    () => mockMessageService.sendSdkMessage(captureAny()),
                  ).captured.single
                  as proto.SdkMessage;
          expect(sent.addToCartRequest.sku, equals('sku-1'));
          expect(sent.addToCartRequest.quantity, equals(3));
        },
      );
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

      test(
        'sends a remove from cart message when no command is registered',
        () async {
          when(() => mockClient.commands).thenReturn({});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.removeFromCart('sku-2', quantity: 2);

          expect(result, isA<Ok<Unit>>());
          final proto.SdkMessage sent =
              verify(
                    () => mockMessageService.sendSdkMessage(captureAny()),
                  ).captured.single
                  as proto.SdkMessage;
          expect(sent.removeFromCartRequest.sku, equals('sku-2'));
          expect(sent.removeFromCartRequest.quantity, equals(2));
        },
      );
    });

    group('updateCartProduct', () {
      test('calls registered command callback instead of service', () async {
        Object? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.updateCartProduct: (payload) => receivedPayload = payload,
        });

        final result = await repo.updateCartProduct('sku-3', 2, 4);

        expect(result, isA<Ok<Unit>>());
        expect(
          receivedPayload,
          equals({'sku': 'sku-3', 'units': 2.0, 'subunits': 4.0}),
        );
        verifyNever(() => mockMessageService.sendSdkMessage(any()));
      });

      test(
        'sends an update cart product message when no command is registered',
        () async {
          when(() => mockClient.commands).thenReturn({});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.updateCartProduct('sku-3', 2, 4);

          expect(result, isA<Ok<Unit>>());
          final proto.SdkMessage sent =
              verify(
                    () => mockMessageService.sendSdkMessage(captureAny()),
                  ).captured.single
                  as proto.SdkMessage;
          expect(sent.updateCartProductRequest.sku, equals('sku-3'));
          expect(sent.updateCartProductRequest.units, equals(2));
          expect(sent.updateCartProductRequest.subunits, equals(4));
        },
      );
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

      test(
        'sends a clear cart message when no command is registered',
        () async {
          when(() => mockClient.commands).thenReturn({});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.clearCart();

          expect(result, isA<Ok<Unit>>());
          final proto.SdkMessage sent =
              verify(
                    () => mockMessageService.sendSdkMessage(captureAny()),
                  ).captured.single
                  as proto.SdkMessage;
          expect(sent.hasClearCartRequest(), isTrue);
        },
      );
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

      test(
        'sends an add promotion message when no command is registered',
        () async {
          when(() => mockClient.commands).thenReturn({});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.addPromotion('promo-abc');

          expect(result, isA<Ok<Unit>>());
          final proto.SdkMessage sent =
              verify(
                    () => mockMessageService.sendSdkMessage(captureAny()),
                  ).captured.single
                  as proto.SdkMessage;
          expect(sent.addPromotionRequest.promotionId, equals('promo-abc'));
        },
      );
    });

    group('requestGuidanceCard', () {
      test('calls registered command callback with the context', () async {
        Object? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          ChatCommand.guidanceCard: (payload) => receivedPayload = payload,
        });

        final result = await repo.requestGuidanceCard(context: 'product-page');

        expect(result, isA<Ok<Unit>>());
        expect(receivedPayload, equals({'context': 'product-page'}));
      });

      test(
        'sends a guidance card request when no command is registered',
        () async {
          when(() => mockClient.commands).thenReturn({});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final result = await repo.requestGuidanceCard();

          expect(result, isA<Ok<Unit>>());
          final proto.SdkMessage sent =
              verify(
                    () => mockMessageService.sendSdkMessage(captureAny()),
                  ).captured.single
                  as proto.SdkMessage;
          expect(sent.hasGuidanceCardRequest(), isTrue);
          expect(sent.correlationId, startsWith('guidance-card-'));
        },
      );
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
        repo
            .messages()
            .where((m) => m.type != MessageType.chatStatus)
            .listen(received.add);
        incoming.add(assistantTextStub);
        await Future.delayed(Duration.zero);

        expect(received, hasLength(1));
      });

      test('resume is a no-op when not paused', () async {
        repo.resume();
        await Future.delayed(Duration.zero);

        verifyNever(() => mockMessageService.messages());
      });
    });

    group('dispose', () {
      test('closes the messages stream', () async {
        final messages = repo.messages();

        repo.dispose();
        await Future.delayed(Duration.zero);

        expect(await messages.isEmpty, isTrue);
      });
    });

    group('custom commands', () {
      proto.PollMessageItem customCommandItem({
        String commandId = 'refreshCatalog',
        String payload = '{"region":"mx"}',
        String correlationId = 'corr-1',
      }) => proto.PollMessageItem(
        id: 'cmd-1',
        message: proto.SdkMessage(
          correlationId: correlationId,
          customCommandRequest: proto.CustomCommandRequest(
            commandId: commandId,
            payload: payload,
          ),
        ),
        date: Timestamp.fromDateTime(DateTime.parse(fixedDate)),
        userId: 'user-123',
        status: 'IN_DELIVERY',
      );

      test('runs the handler found by command id and sends a success '
          'response', () async {
        String? receivedPayload;
        when(() => mockClient.commands).thenReturn({
          'refreshCatalog': (payload) {
            receivedPayload = payload;
            return '{"done":true}';
          },
        });
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        repo.messages().listen((_) {});
        incoming.add(customCommandItem());
        await pumpEventQueue();

        expect(receivedPayload, '{"region":"mx"}');
        final sent =
            verify(
                  () => mockMessageService.sendSdkMessage(captureAny()),
                ).captured.single
                as proto.SdkMessage;
        expect(sent.correlationId, 'corr-1');
        expect(
          sent.customCommandResponse.status,
          proto.ResponseStatus.RESPONSE_STATUS_SUCCESS,
        );
        expect(sent.customCommandResponse.payload, '{"done":true}');
      });

      test('sends an empty payload when the handler returns null', () async {
        when(
          () => mockClient.commands,
        ).thenReturn({'refreshCatalog': (_) => null});
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        repo.messages().listen((_) {});
        incoming.add(customCommandItem());
        await pumpEventQueue();

        final sent =
            verify(
                  () => mockMessageService.sendSdkMessage(captureAny()),
                ).captured.single
                as proto.SdkMessage;
        expect(
          sent.customCommandResponse.status,
          proto.ResponseStatus.RESPONSE_STATUS_SUCCESS,
        );
        expect(sent.customCommandResponse.payload, isEmpty);
      });

      test('sends an error response when the handler throws', () async {
        when(
          () => mockClient.commands,
        ).thenReturn({'refreshCatalog': (_) => throw Exception('boom')});
        when(
          () => mockMessageService.sendSdkMessage(any()),
        ).thenAnswer((_) async => Result.ok(Unit()));

        repo.messages().listen((_) {});
        incoming.add(customCommandItem());
        await pumpEventQueue();

        final sent =
            verify(
                  () => mockMessageService.sendSdkMessage(captureAny()),
                ).captured.single
                as proto.SdkMessage;
        expect(
          sent.customCommandResponse.status,
          proto.ResponseStatus.RESPONSE_STATUS_ERROR,
        );
        expect(sent.customCommandResponse.payload, isEmpty);
      });

      test(
        'sends no response when no handler is registered for the id',
        () async {
          when(() => mockClient.commands).thenReturn({});

          repo.messages().listen((_) {});
          incoming.add(customCommandItem(commandId: 'unknown'));
          await pumpEventQueue();

          verifyNever(() => mockMessageService.sendSdkMessage(any()));
        },
      );

      test(
        'does not emit a custom command request as a chat message',
        () async {
          when(
            () => mockClient.commands,
          ).thenReturn({'refreshCatalog': (_) => null});
          when(
            () => mockMessageService.sendSdkMessage(any()),
          ).thenAnswer((_) async => Result.ok(Unit()));

          final received = <ChatMessage>[];
          repo
              .messages()
              .where((m) => m.type != MessageType.chatStatus)
              .listen(received.add);
          incoming.add(customCommandItem());
          await pumpEventQueue();

          expect(received, isEmpty);
        },
      );
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
