// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

class YaloMessageServiceRemote implements YaloMessageService {
  final String _baseUrl;
  final String _channelId;
  final YaloMessageAuthService _authService;
  final Client _httpClient;
  final Logger log = Logger('YaloMessagerepositoryremote');

  YaloMessageServiceRemote({
    required String baseUrl,
    required String channelId,
    required YaloMessageAuthService authService,
    Client? httpClient,
  }) : _baseUrl = baseUrl,
       _channelId = channelId,
       _authService = authService,
       _httpClient = httpClient ?? Client();

  @override
  Future<Result<Unit>> sendSdkMessage(SdkMessage request) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final entry = (authResult as Ok<TokenEntry>).result;

    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/inapp/inbound_messages'),
        headers: {
          'content-type': 'application/json',
          'x-user-id': entry.userId,
          'x-channel-id': _channelId,
          'authorization': 'Bearer ${entry.accessToken}',
        },
        body: jsonEncode(request.toProto3Json()),
      );

      log.info(jsonEncode(request.toProto3Json()));

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
  Future<Result<List<PollMessageItem>>> fetchMessages(int since) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final entry = (authResult as Ok<TokenEntry>).result;

    try {
      final baseUrl = '$_baseUrl/inapp/messages';
      //FIXME: wait for backend fix
      //final queryParams = {'since': '$since'};
      //final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final uri = Uri.parse(baseUrl);
      final response = await _httpClient.get(
        uri,
        headers: {
          'x-user-id': entry.userId,
          'x-channel-id': _channelId,
          'authorization': 'Bearer ${entry.accessToken}',
        },
      );
      if (response.statusCode == 200) {
        final data = (jsonDecode(response.body) as List<dynamic>)
            .map((json) => PollMessageItem.create()..mergeFromProto3Json(json))
            .toList();
        return Result.ok(data);
      }
      return Result.error(Exception('Error fetching messages $response'));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
