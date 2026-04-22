// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service_remote.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class MockYaloMessageAuthService extends Mock
    implements YaloMessageAuthService {}

class MockClient extends Mock implements Client {}

String _makeJwtToken(String userId) {
  final payload = base64Url
      .encode(utf8.encode('{"user_id":"$userId"}'))
      .replaceAll('=', '');
  return 'header.$payload.signature';
}

TokenEntry _makeTokenEntry(String token, String userId) => TokenEntry(
  accessToken: token,
  userId: userId,
  refreshToken: '',
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
);

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse(''));
  });

  group('YaloMessageServiceRemote', () {
    late MockYaloMessageAuthService mockAuthService;
    late MockClient mockClient;
    late YaloMessageServiceRemote service;

    const baseUrl = 'https://api.example.com';
    const channelId = 'ch-1';
    const userId = 'user-123';

    setUp(() {
      mockAuthService = MockYaloMessageAuthService();
      mockClient = MockClient();
      service = YaloMessageServiceRemote(
        baseUrl: baseUrl,
        channelId: channelId,
        authService: mockAuthService,
        httpClient: mockClient,
      );
    });

    final testRequest = SdkMessage(
      correlationId: "1",
      textMessageRequest: TextMessageRequest(
        content: TextMessage(
          text: 'Hello',
          role: MessageRole.MESSAGE_ROLE_USER,
          status: MessageStatus.MESSAGE_STATUS_SENT,
        ),
      ),
    );

    group('sendSdkMessage', () {
      test('propagates auth error without calling post', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.sendSdkMessage(testRequest);

        expect(result, isA<Error<Unit>>());
        verifyNever(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        );
      });

      test('POSTs to correct URL with correct headers and body', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        await service.sendSdkMessage(testRequest);

        final captured = verify(
          () => mockClient.post(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final capturedUri = captured[0] as Uri;
        final capturedHeaders = captured[1] as Map<String, String>;
        final capturedBody = captured[2] as String;

        expect(
          capturedUri.toString(),
          equals('$baseUrl/inapp/inbound_messages'),
        );
        expect(capturedHeaders['x-user-id'], equals(userId));
        expect(capturedHeaders['x-channel-id'], equals(channelId));
        expect(capturedHeaders['authorization'], equals('Bearer $token'));
        expect(capturedHeaders['content-type'], equals('application/json'));
        expect(capturedBody, equals(jsonEncode(testRequest.toProto3Json())));
      });

      test('returns Ok(Unit) on 200', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        final result = await service.sendSdkMessage(testRequest);

        expect(result, isA<Ok<Unit>>());
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 401));

        final result = await service.sendSdkMessage(testRequest);

        expect(result, isA<Error<Unit>>());
      });

      test('returns Error when client throws', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('network error'));

        final result = await service.sendSdkMessage(testRequest);

        expect(result, isA<Error<Unit>>());
      });
    });

    group('fetchMessages', () {
      const since = 1704067200000;

      test('propagates auth error without calling get', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.fetchMessages(since);

        expect(result, isA<Error<List>>());
        verifyNever(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        );
      });

      test('GETs URL with correct since query param', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('[]', 200));

        await service.fetchMessages(since);

        final captured = verify(
          () => mockClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured;

        final capturedUri = captured[0] as Uri;
        expect(capturedUri.queryParameters['since'], equals('$since'));
        expect(capturedUri.path, endsWith('/inapp/messages'));
      });

      test('sends correct headers', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('[]', 200));

        await service.fetchMessages(since);

        final captured = verify(
          () => mockClient.get(any(), headers: captureAny(named: 'headers')),
        ).captured;

        final capturedHeaders = captured[0] as Map<String, String>;
        expect(capturedHeaders['x-user-id'], equals(userId));
        expect(capturedHeaders['x-channel-id'], equals(channelId));
        expect(capturedHeaders['authorization'], equals('Bearer $token'));
      });

      test('returns parsed list on 200 with one-item JSON array', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        const responseBody = '''
        [
          {
            "id": "3a73bc83-b4da-4fef-a83e-21310edc0283",
            "message": {
              "timestamp": "2026-03-26T16:51:35.766Z",
              "textMessageRequest": {
                "content": {
                  "text": "Your context has been reset."
                }
              }
            },
            "date": "2026-03-26T16:51:36Z",
            "user_id": "c2420cb3-08eb-4ca4-b299-7c04c195f413",
            "status": "IN_DELIVERY"
          }
        ]''';
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response(responseBody, 200));

        final result = await service.fetchMessages(since);

        expect(result, isA<Ok>());
        final list = (result as Ok<List<PollMessageItem>>).result;
        expect(list, hasLength(1));
        expect(list.first.id, equals('3a73bc83-b4da-4fef-a83e-21310edc0283'));
        expect(
          list.first.message.textMessageRequest.content.text,
          equals('Your context has been reset.'),
        );
        expect(
          list.first.message.textMessageRequest.content.role,
          equals(MessageRole.MESSAGE_ROLE_UNSPECIFIED),
        );
        expect(
          list.first.userId,
          equals('c2420cb3-08eb-4ca4-b299-7c04c195f413'),
        );
        expect(list.first.status, equals("IN_DELIVERY"));
      });

      test('returns Ok with empty list on 200 with empty array', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('[]', 200));

        final result = await service.fetchMessages(since);

        expect(result, isA<Ok>());
        expect((result as Ok).result, isEmpty);
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('', 500));

        final result = await service.fetchMessages(since);

        expect(result, isA<Error>());
      });

      test('returns Error when client throws', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenThrow(Exception('network error'));

        final result = await service.fetchMessages(since);

        expect(result, isA<Error>());
      });
    });

    group('addToCart', () {
      test('propagates auth error', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.addToCart('sku-1', 3);

        expect(result, isA<Error<Unit>>());
        verifyNever(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        );
      });

      test('sends SdkMessage with AddToCartRequest', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        final result = await service.addToCart('sku-1', 3);

        expect(result, isA<Ok<Unit>>());

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        expect(body['correlationId'], startsWith('add-to-cart-sku-1-'));
        expect(body['addToCartRequest']['sku'], equals('sku-1'));
        expect(body['addToCartRequest']['quantity'], equals(3));
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 500));

        final result = await service.addToCart('sku-1', 3);

        expect(result, isA<Error<Unit>>());
      });
    });

    group('removeFromCart', () {
      test('propagates auth error', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.removeFromCart('sku-2');

        expect(result, isA<Error<Unit>>());
      });

      test('sends SdkMessage with RemoveFromCartRequest including quantity',
          () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        final result = await service.removeFromCart('sku-2', quantity: 2);

        expect(result, isA<Ok<Unit>>());

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        expect(
          body['correlationId'],
          startsWith('remove-from-cart-sku-2-'),
        );
        expect(body['removeFromCartRequest']['sku'], equals('sku-2'));
        expect(body['removeFromCartRequest']['quantity'], equals(2));
      });

      test('omits quantity when not provided', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        await service.removeFromCart('sku-2');

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        expect(
          body['removeFromCartRequest'].containsKey('quantity'),
          isFalse,
        );
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 500));

        final result = await service.removeFromCart('sku-2', quantity: 1);

        expect(result, isA<Error<Unit>>());
      });
    });

    group('clearCart', () {
      test('propagates auth error', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.clearCart();

        expect(result, isA<Error<Unit>>());
      });

      test('sends SdkMessage with ClearCartRequest', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        final result = await service.clearCart();

        expect(result, isA<Ok<Unit>>());

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        expect(body['correlationId'], startsWith('clear-cart-'));
        expect(body.containsKey('clearCartRequest'), isTrue);
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 500));

        final result = await service.clearCart();

        expect(result, isA<Error<Unit>>());
      });
    });

    group('addPromotion', () {
      test('propagates auth error', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.addPromotion('promo-abc');

        expect(result, isA<Error<Unit>>());
      });

      test('sends SdkMessage with AddPromotionRequest', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        final result = await service.addPromotion('promo-abc');

        expect(result, isA<Ok<Unit>>());

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        expect(
          body['correlationId'],
          startsWith('add-promotion-promo-abc-'),
        );
        expect(
          body['addPromotionRequest']['promotionId'],
          equals('promo-abc'),
        );
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token, userId)));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 500));

        final result = await service.addPromotion('promo-abc');

        expect(result, isA<Error<Unit>>());
      });
    });
  });
}
