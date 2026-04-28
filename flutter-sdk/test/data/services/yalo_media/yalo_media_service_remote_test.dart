// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';
import 'dart:typed_data';

import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service_remote.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class MockYaloMessageAuthService extends Mock
    implements YaloMessageAuthService {}

class MockClient extends Mock implements Client {}

TokenEntry _makeTokenEntry(String token) => TokenEntry(
  accessToken: token,
  userId: 'user-123',
  refreshToken: '',
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
);

const _responseBody = '''
{
  "id": "yalo_63cfd924-19dc-455a-b755-c949e62fc4e7",
  "signed_url": "https://storage.googleapis.com/example/file.jpeg",
  "original_name": "photo.jpeg",
  "type": "image",
  "metadata": {"user_id": "abc123"},
  "created_at": "2026-03-19T15:56:21.629107809Z",
  "expires_at": "2026-03-19T16:56:21.190587072Z"
}
''';

void main() {
  setUpAll(() {
    registerFallbackValue(Request('GET', Uri.parse('')));
  });

  group('YaloMediaServiceRemote', () {
    late MockYaloMessageAuthService mockAuthService;
    late MockClient mockClient;
    late YaloMediaServiceRemote service;

    const baseUrl = 'https://api.example.com';
    const token = 'test-token';

    setUp(() {
      mockAuthService = MockYaloMessageAuthService();
      mockClient = MockClient();
      service = YaloMediaServiceRemote(
        baseUrl: baseUrl,
        authService: mockAuthService,
        httpClient: mockClient,
      );
    });

    XFile makeXFile() => XFile.fromData(
      utf8.encode('fake image bytes'),
      name: 'photo.jpeg',
      mimeType: 'image/jpeg',
    );

    StreamedResponse makeStreamedResponse(int statusCode, String body) =>
        StreamedResponse(Stream.value(utf8.encode(body)), statusCode);

    group('uploadMedia', () {
      test('propagates auth error without calling send', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.error(Exception('auth failed')));

        final result = await service.uploadMedia(makeXFile());

        expect(result, isA<Error<MediaUploadResponse>>());
        verifyNever(() => mockClient.send(any()));
      });

      test('POSTs to correct URL with Authorization header', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token)));
        when(
          () => mockClient.send(any()),
        ).thenAnswer((_) async => makeStreamedResponse(201, _responseBody));

        await service.uploadMedia(makeXFile());

        final captured = verify(() => mockClient.send(captureAny())).captured;
        final request = captured.first as MultipartRequest;

        expect(request.url.toString(), equals('$baseUrl/all/media'));
        expect(request.headers['Authorization'], equals('Bearer $token'));
        expect(request.files, hasLength(1));
        expect(request.files.first.field, equals('file'));
      });

      test('returns Ok<MediaUploadResponse> on 201 with valid JSON', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token)));
        when(
          () => mockClient.send(any()),
        ).thenAnswer((_) async => makeStreamedResponse(201, _responseBody));

        final result = await service.uploadMedia(makeXFile());

        expect(result, isA<Ok<MediaUploadResponse>>());
        final response = (result as Ok<MediaUploadResponse>).result;
        expect(
          response.id,
          equals('yalo_63cfd924-19dc-455a-b755-c949e62fc4e7'),
        );
        expect(
          response.signedUrl,
          equals('https://storage.googleapis.com/example/file.jpeg'),
        );
        expect(response.originalName, equals('photo.jpeg'));
        expect(response.type, equals('image'));
        expect(response.metadata['user_id'], equals('abc123'));
      });

      test('returns Error on non-201 response', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token)));
        when(
          () => mockClient.send(any()),
        ).thenAnswer((_) async => makeStreamedResponse(400, ''));

        final result = await service.uploadMedia(makeXFile());

        expect(result, isA<Error<MediaUploadResponse>>());
      });

      test('returns Error when client throws', () async {
        when(
          () => mockAuthService.auth(),
        ).thenAnswer((_) async => Result.ok(_makeTokenEntry(token)));
        when(
          () => mockClient.send(any()),
        ).thenThrow(Exception('network error'));

        final result = await service.uploadMedia(makeXFile());

        expect(result, isA<Error<MediaUploadResponse>>());
      });
    });

    group('downloadMedia', () {
      const imageUrl = 'https://example.com/image.jpg';
      final imageBytes = Uint8List.fromList([1, 2, 3, 4]);

      test('returns Ok<Uint8List> on 200', () async {
        when(
          () => mockClient.get(Uri.parse(imageUrl)),
        ).thenAnswer((_) async => Response.bytes(imageBytes, 200));

        final result = await service.downloadMedia(imageUrl);

        expect(result, isA<Ok<Uint8List>>());
        expect((result as Ok<Uint8List>).result, equals(imageBytes));
      });

      test('returns Error on non-200 response', () async {
        when(
          () => mockClient.get(Uri.parse(imageUrl)),
        ).thenAnswer((_) async => Response('', 404));

        final result = await service.downloadMedia(imageUrl);

        expect(result, isA<Error<Uint8List>>());
      });

      test('returns Error when client throws', () async {
        when(
          () => mockClient.get(Uri.parse(imageUrl)),
        ).thenThrow(Exception('network error'));

        final result = await service.downloadMedia(imageUrl);

        expect(result, isA<Error<Uint8List>>());
      });
    });
  });
}
