// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service_remote.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';
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

    final testRequest = YaloTextMessageRequest(
      timestamp: 1000,
      content: const YaloTextMessage(
        timestamp: 1000,
        text: 'Hello',
        status: 'sent',
        role: 'USER',
      ),
    );

    group('sendTextMessage', () {
      test('propagates auth error without calling post', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.sendTextMessage(testRequest);

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
        ).thenAnswer((_) async => Result.ok(token));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        await service.sendTextMessage(testRequest);

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
          equals('$baseUrl/webchat/inbound_messages'),
        );
        expect(capturedHeaders['x-user-id'], equals(userId));
        expect(capturedHeaders['x-channel-id'], equals(channelId));
        expect(capturedHeaders['authorization'], equals('Bearer $token'));
        expect(capturedHeaders['content-type'], equals('application/json'));
        expect(capturedBody, equals(jsonEncode(testRequest.toJson())));
      });

      test('returns Ok(Unit) on 200', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(token));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        final result = await service.sendTextMessage(testRequest);

        expect(result, isA<Ok<Unit>>());
      });

      test('returns Error on non-200 response', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(token));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 401));

        final result = await service.sendTextMessage(testRequest);

        expect(result, isA<Error<Unit>>());
      });

      test('returns Error when client throws', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(token));
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('network error'));

        final result = await service.sendTextMessage(testRequest);

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
        ).thenAnswer((_) async => Result.ok(token));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('[]', 200));

        await service.fetchMessages(since);

        final captured = verify(
          () => mockClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured;

        final capturedUri = captured[0] as Uri;
        expect(capturedUri.queryParameters['since'], equals('$since'));
        expect(capturedUri.path, endsWith('/webchat/messages'));
      });

      test('sends correct headers', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(token));
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
        ).thenAnswer((_) async => Result.ok(token));
        const responseBody =
            '[{"id":"msg-1","message":{"text":"Hi","role":"AGENT"},'
            '"date":"2024-01-01T00:00:00.000Z","user_id":"user-123","status":"delivered"}]';
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response(responseBody, 200));

        final result = await service.fetchMessages(since);

        expect(result, isA<Ok>());
        final list = (result as Ok).result;
        expect(list, hasLength(1));
        expect(list.first.id, equals('msg-1'));
        expect(list.first.message.text, equals('Hi'));
        expect(list.first.message.role, equals('AGENT'));
        expect(list.first.userId, equals('user-123'));
        expect(list.first.status, equals('delivered'));
      });

      test('returns Ok with empty list on 200 with empty array', () async {
        final token = _makeJwtToken(userId);
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(token));
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
        ).thenAnswer((_) async => Result.ok(token));
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
        ).thenAnswer((_) async => Result.ok(token));
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenThrow(Exception('network error'));

        final result = await service.fetchMessages(since);

        expect(result, isA<Error>());
      });
    });
  });
}
