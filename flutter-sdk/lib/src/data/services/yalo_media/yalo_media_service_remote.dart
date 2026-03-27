// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';
import 'dart:typed_data';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_media/media_upload_response.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_media/yalo_media_service.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';

class YaloMediaServiceRemote implements YaloMediaService {
  final String _baseUrl;
  final YaloMessageAuthService _authService;
  final Client _httpClient;
  final Logger log = Logger('YaloMediaServiceRemote');

  YaloMediaServiceRemote({
    required String baseUrl,
    required YaloMessageAuthService authService,
    Client? httpClient,
  }) : _baseUrl = baseUrl,
       _authService = authService,
       _httpClient = httpClient ?? Client();

  @override
  Future<Result<MediaUploadResponse>> uploadMedia(XFile file) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final entry = (authResult as Ok<TokenEntry>).result;

    try {
      final bytes = await file.readAsBytes();
      final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';

      final request = MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/all/media'),
      );

      log.info('Sending mime type $mimeType');
      request.headers['Authorization'] = 'Bearer ${entry.accessToken}';
      request.files.add(
        MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
          contentType: MediaType.parse(mimeType),
        ),
      );

      final streamedResponse = await _httpClient.send(request);
      final response = await Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        return Result.ok(MediaUploadResponse.fromJson(json));
      } else {
        log.severe('Unable to upload media', response.body);
        return Result.error(
          Exception('Failed to upload media: ${response.statusCode}'),
        );
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<Uint8List>> downloadMedia(String url) async {
    try {
      final response = await _httpClient.get(Uri.parse(url));
      if (response.statusCode == 200) return Result.ok(response.bodyBytes);
      return Result.error(
        Exception('Failed to download media: ${response.statusCode}'),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
