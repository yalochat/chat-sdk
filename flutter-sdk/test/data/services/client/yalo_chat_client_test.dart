// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_fetch_messages_response.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements Client {}

void main() {
  group(YaloChatClient, () {
    late MockHttpClient mockHttpClient;
    late YaloChatClient client;

    const testName = 'test name';
    const testFlowKey = 'test-flow-key';
    const testAuthToken = 'test-auth-token';
    const testUserToken = 'test-user-token';

    setUpAll(() {
      registerFallbackValue(Uri());
      registerFallbackValue(<String, String>{});
    });

    setUp(() {
      mockHttpClient = MockHttpClient();
      client = YaloChatClient(
        name: testName,
        flowKey: testFlowKey,
        authToken: testAuthToken,
        userToken: testUserToken,
        httpClient: mockHttpClient,
      );
    });

    group('constructor', () {
      test('initializes a new httpclient if it is not sent', () {
        YaloChatClient testClient = client = YaloChatClient(
          name: testName,
          flowKey: testFlowKey,
          authToken: testAuthToken,
          userToken: testUserToken,
        );

        expect(testClient.httpClient, isA<Client>());
      });
    });

    group('registerAction', () {
      test('adds an action with the correct name and callback', () {
        bool wasCalled = false;
        client.registerAction('myAction', () => wasCalled = true);

        expect(client.actions, hasLength(1));
        expect(client.actions.first.name, equals('myAction'));

        client.actions.first.action();
        expect(wasCalled, isTrue);
      });

      test('accumulates multiple actions in registration order', () {
        client.registerAction('first', () {});
        client.registerAction('second', () {});
        client.registerAction('third', () {});

        expect(client.actions, hasLength(3));
        expect(
          client.actions.map((a) => a.name),
          equals(['first', 'second', 'third']),
        );
      });
    });

    group('sendTextMessage', () {
      late YaloTextMessageRequest request;

      setUp(() {
        request = const YaloTextMessageRequest(
          timestamp: 1000,
          content: YaloTextMessage(
            timestamp: 1000,
            text: 'Hello',
            status: 'sent',
            role: 'user',
          ),
        );
      });

      test(
        'returns Result.ok(Unit()) when the server responds with HTTP 200',
        () async {
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => Response('', 200));

          final result = await client.sendTextMessage(request);

          expect(result, equals(Result.ok(Unit())));
        },
      );

      test(
        'returns Result.error when the server responds with HTTP 400',
        () async {
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => Response('Bad Request', 400));

          final result = await client.sendTextMessage(request);

          expect(result, isA<Error<Unit>>());
          final error = (result as Error<Unit>).error;
          expect(error.toString(), contains('400'));
        },
      );

      test(
        'returns Result.error when the server responds with HTTP 500',
        () async {
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenAnswer((_) async => Response('Internal Server Error', 500));

          final result = await client.sendTextMessage(request);

          expect(result, isA<Error<Unit>>());
          final error = (result as Error<Unit>).error;
          expect(error.toString(), contains('500'));
        },
      );

      test(
        'returns Result.error when httpClient throws an Exception',
        () async {
          final networkError = Exception('Network unreachable');
          when(
            () => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            ),
          ).thenThrow(networkError);

          final result = await client.sendTextMessage(request);

          expect(result, isA<Error<Unit>>());
          final error = (result as Error<Unit>).error;
          expect(error.toString(), contains('Network unreachable'));
        },
      );

      test('sends correct headers in the POST request', () async {
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        await client.sendTextMessage(request);

        final captured = verify(
          () => mockHttpClient.post(
            any(),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final headers = captured.first as Map<String, String>;
        expect(headers['content-type'], equals('application/json'));
        expect(headers['x-user-id'], equals(testUserToken));
        expect(headers['x-channel-id'], equals(testFlowKey));
        expect(headers['authorization'], equals('Bearer $testAuthToken'));
      });

      test('sends the request body as JSON-encoded request payload', () async {
        when(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 200));

        await client.sendTextMessage(request);

        final captured = verify(
          () => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body =
            jsonDecode(captured.first as String) as Map<String, dynamic>;
        expect(body['timestamp'], equals(request.timestamp));
      });
    });

    group('fetchMessages', () {
      const since = 1700000000;

      final responseJson = jsonEncode([
        {
          'id': 'msg-1',
          'message': {'text': 'Hello there', 'role': 'agent'},
          'date': '2024-01-01T00:00:00Z',
          'user_id': 'user-abc',
          'status': 'delivered',
        },
        {
          'id': 'msg-2',
          'message': {'text': 'How can I help?', 'role': 'agent'},
          'date': '2024-01-01T00:00:01Z',
          'user_id': 'user-abc',
          'status': 'read',
        },
      ]);

      test(
        'returns Result.ok with parsed list when the server responds with HTTP 200',
        () async {
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => Response(responseJson, 200));

          final result = await client.fetchMessages(since);

          expect(result, isA<Ok<List<YaloFetchMessagesResponse>>>());
          final messages =
              (result as Ok<List<YaloFetchMessagesResponse>>).result;
          expect(messages, hasLength(2));
          expect(messages[0].id, equals('msg-1'));
          expect(
            messages[0].message,
            equals(const YaloMessage(text: 'Hello there', role: 'agent')),
          );
          expect(messages[0].userId, equals('user-abc'));
          expect(messages[0].status, equals('delivered'));
          expect(messages[1].id, equals('msg-2'));
        },
      );

      test(
        'returns Result.ok with empty list when the server returns an empty JSON array',
        () async {
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => Response('[]', 200));

          final result = await client.fetchMessages(since);

          expect(result, isA<Ok<List<YaloFetchMessagesResponse>>>());
          final messages =
              (result as Ok<List<YaloFetchMessagesResponse>>).result;
          expect(messages, isEmpty);
        },
      );

      test(
        'returns Result.error when the server responds with a non-200 status',
        () async {
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenAnswer((_) async => Response('Internal Server Error', 500));

          final result = await client.fetchMessages(since);

          expect(result, isA<Error<List<YaloFetchMessagesResponse>>>());
        },
      );

      test(
        'returns Result.error when httpClient throws an Exception',
        () async {
          final networkError = Exception('Connection timed out');
          when(
            () => mockHttpClient.get(any(), headers: any(named: 'headers')),
          ).thenThrow(networkError);

          final result = await client.fetchMessages(since);

          expect(result, isA<Error<List<YaloFetchMessagesResponse>>>());
          final error =
              (result as Error<List<YaloFetchMessagesResponse>>).error;
          expect(error.toString(), contains('Connection timed out'));
        },
      );

      test('sends correct headers in the GET request', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('[]', 200));

        await client.fetchMessages(since);

        final captured = verify(
          () =>
              mockHttpClient.get(any(), headers: captureAny(named: 'headers')),
        ).captured;

        final headers = captured.first as Map<String, String>;
        expect(headers['x-user-id'], equals(testUserToken));
        expect(headers['x-channel-id'], equals(testFlowKey));
        expect(headers['authorization'], equals('Bearer $testAuthToken'));
      });

      test('includes the since timestamp as a query parameter', () async {
        when(
          () => mockHttpClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => Response('[]', 200));

        await client.fetchMessages(since);

        final captured = verify(
          () =>
              mockHttpClient.get(captureAny(), headers: any(named: 'headers')),
        ).captured;

        final uri = captured.first as Uri;
        expect(uri.queryParameters['since'], equals('$since'));
      });
    });
  });
}
