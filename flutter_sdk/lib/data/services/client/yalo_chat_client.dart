// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_fetch_messages_response.dart';
import 'package:chat_flutter_sdk/src/domain/models/yalo_message/yalo_text_message_request.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

class Action {
  final String name;
  final void Function() action;

  Action({required this.name, required this.action});
}

class YaloChatClient {
  final String name;
  final String flowKey;
  final String userToken;
  final String authToken;
  final String chatBaseUrl;
  final List<Action> actions;
  final Logger log = Logger('YaloChatClient');
  final Client httpClient;

  YaloChatClient({
    required this.name,
    required this.flowKey,
    // FIXME: Remove this one
    required this.authToken,
    required this.userToken,
    Client? httpClient,
  }) : chatBaseUrl = const String.fromEnvironment('YALO_SDK_CHAT_URL'),
       actions = [], httpClient = httpClient ?? Client();

  void registerAction(String actionName, void Function() action) {
    actions.add(Action(name: actionName, action: action));
  }

  // Sends a yalo text message to the upstream chat service
  Future<Result<Unit>> sendTextMessage(YaloTextMessageRequest request) async {
    try {

      final response = await httpClient.post(
        Uri.parse('$chatBaseUrl/inbound_messages'),
        headers: {
          'content-type': 'application/json',
          'x-user-id': userToken,
          'x-channel-id': flowKey,
          'authorization': 'Bearer $authToken',
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

  // Fetches messages from the chat service, the "since" argument
  // is a unix timestamp.
  Future<Result<List<YaloFetchMessagesResponse>>> fetchMessages(
    int since,
  ) async {
    try {
      final baseUrl = '$chatBaseUrl/messages';
      final queryParams = {'since': '$since'};
      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await httpClient.get(
        uri,
        headers: {
          'x-user-id': userToken,
          'x-channel-id': flowKey,
          'authorization': 'Bearer $authToken',
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
}
