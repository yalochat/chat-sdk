// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_fetch_messages_response.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';
import 'package:http/http.dart';

class YaloMessageServiceRemote implements YaloMessageService {
  final String _baseUrl;
  final String _channelId;
  final YaloMessageAuthService _authService;
  final Client _httpClient;

  YaloMessageServiceRemote({
    required String baseUrl,
    required String channelId,
    required YaloMessageAuthService authService,
    Client? httpClient,
  })  : _baseUrl = baseUrl,
        _channelId = channelId,
        _authService = authService,
        _httpClient = httpClient ?? Client();

  @override
  Future<Result<Unit>> sendTextMessage(YaloTextMessageRequest request) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final token = (authResult as Ok<String>).result;
    final userId = _decodeUserId(token);

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/webchat/inbound_messages'),
        headers: {
          'content-type': 'application/json',
          'x-user-id': userId,
          'x-channel-id': _channelId,
          'authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        return Result.ok(Unit());
      } else {
        return Result.error(
          Exception('Failed to send message: ${response.statusCode}'),
        );
      }
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<List<YaloFetchMessagesResponse>>> fetchMessages(
    int since,
  ) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final token = (authResult as Ok<String>).result;
    final userId = _decodeUserId(token);

    try {
      final baseUrl = '$_baseUrl/webchat/messages';
      final queryParams = {'since': '$since'};
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await _httpClient.get(
        uri,
        headers: {
          'x-user-id': userId,
          'x-channel-id': _channelId,
          'authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = YaloFetchMessagesResponse.fromJsonList(
          jsonDecode(response.body),
        );
        return Result.ok(data);
      }
      return Result.error(Exception('Error fetching messages $response'));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  String _decodeUserId(String token) {
    final parts = token.split('.');
    final normalized = base64Url.normalize(parts[1]);
    final payload =
        jsonDecode(utf8.decode(base64Url.decode(normalized)))
            as Map<String, dynamic>;
    return payload['user_id'] as String;
  }
}
