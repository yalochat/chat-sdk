// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service_remote.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

class MockClient extends Mock implements Client {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri.parse(''));
  });

  group('YaloMessageAuthServiceRemote', () {
    late MockClient mockClient;
    late YaloMessageAuthServiceRemote service;

    const baseUrl = 'https://api.example.com';
    const channelId = 'ch-1';
    const organizationId = 'org-1';

    const accessToken = 'access-token-abc';
    const refreshToken = 'refresh-token-xyz';

    /// A response body that yields a non-expired token (expires in 1 hour).
    String authResponseBody({
      String access = accessToken,
      String refresh = refreshToken,
      int expiresIn = 3600,
    }) =>
        jsonEncode({
          'access_token': access,
          'refresh_token': refresh,
          'expires_in': expiresIn,
        });

    /// A response body with expires_in=0 so the token is immediately stale.
    String expiredAuthResponseBody() => authResponseBody(expiresIn: 0);

    setUp(() {
      mockClient = MockClient();
      service = YaloMessageAuthServiceRemote(
        baseUrl: baseUrl,
        channelId: channelId,
        organizationId: organizationId,
        httpClient: mockClient,
      );
    });

    group('auth — no cache', () {
      test('POSTs to $baseUrl/auth with correct headers', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(authResponseBody(), 200));

        await service.auth();

        final captured = verify(
          () => mockClient.post(
            captureAny(),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).captured;

        final uri = captured[0] as Uri;
        final headers = captured[1] as Map<String, String>;

        expect(uri.toString(), equals('$baseUrl/auth'));
        expect(headers['Content-Type'], equals('application/json'));
      });

      test('POSTs body with user_type, channel_id and organization_id',
          () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(authResponseBody(), 200));

        await service.auth();

        final captured = verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final body = jsonDecode(captured[0] as String) as Map<String, dynamic>;
        expect(body['user_type'], equals('anonymous'));
        expect(body['channel_id'], equals(channelId));
        expect(body['organization_id'], equals(organizationId));
        expect(body['timestamp'], isA<int>());
      });

      test('returns Ok with access_token on 200', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(authResponseBody(), 200));

        final result = await service.auth();

        expect(result, isA<Ok<String>>());
        expect((result as Ok<String>).result, equals(accessToken));
      });

      test('returns Error on non-200', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 401));

        final result = await service.auth();

        expect(result, isA<Error<String>>());
      });

      test('returns Error when client throws', () async {
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('network error'));

        final result = await service.auth();

        expect(result, isA<Error<String>>());
      });
    });

    group('auth — valid cache', () {
      test('returns cached token without making HTTP call', () async {
        // Populate the cache with a non-expired token.
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(authResponseBody(), 200));
        await service.auth();

        // Second call must not hit the network.
        final result = await service.auth();

        // post was only called once (during the first auth()).
        verify(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).called(1);
        expect(result, isA<Ok<String>>());
        expect((result as Ok<String>).result, equals(accessToken));
      });
    });

    group('auth — expired cache', () {
      test('uses refresh token when cached token has expired', () async {
        // First: populate cache with an immediately-expiring token.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/auth'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(expiredAuthResponseBody(), 200));
        await service.auth();

        // Second: refresh endpoint must be called.
        const newAccessToken = 'new-access-token';
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/oauth/token'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async => Response(
            authResponseBody(access: newAccessToken),
            200,
          ),
        );

        final result = await service.auth();

        expect(result, isA<Ok<String>>());
        expect((result as Ok<String>).result, equals(newAccessToken));
      });

      test('POSTs to $baseUrl/oauth/token with form-encoded body on refresh',
          () async {
        // Seed an expired cache.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/auth'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(expiredAuthResponseBody(), 200));
        await service.auth();

        // Intercept the refresh call.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/oauth/token'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(authResponseBody(), 200));

        await service.auth();

        final captured = verify(
          () => mockClient.post(
            Uri.parse('$baseUrl/oauth/token'),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          ),
        ).captured;

        final headers = captured[0] as Map<String, String>;
        final body = captured[1] as Map<String, String>;

        expect(
          headers['Content-Type'],
          equals('application/x-www-form-urlencoded'),
        );
        expect(body['grant_type'], equals('refresh_token'));
        expect(body['refresh_token'], equals(refreshToken));
      });

      test('clears cache and returns Error when refresh returns non-200',
          () async {
        // Seed an expired cache.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/auth'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(expiredAuthResponseBody(), 200));
        await service.auth();

        // Refresh fails.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/oauth/token'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response('', 401));

        final result = await service.auth();

        expect(result, isA<Error<String>>());

        // After cache is cleared a third auth() call goes back to /auth.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/auth'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(authResponseBody(), 200));

        await service.auth();

        verify(
          () => mockClient.post(
            Uri.parse('$baseUrl/auth'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).called(2); // original fetch + post-clear fetch
      });

      test('returns Error when refresh client throws', () async {
        // Seed an expired cache.
        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/auth'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => Response(expiredAuthResponseBody(), 200));
        await service.auth();

        when(
          () => mockClient.post(
            Uri.parse('$baseUrl/oauth/token'),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('network error'));

        final result = await service.auth();

        expect(result, isA<Error<String>>());
      });
    });
  });
}
