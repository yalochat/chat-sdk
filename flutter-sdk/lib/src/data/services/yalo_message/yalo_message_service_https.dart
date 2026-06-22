// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:convert';

import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';

class YaloMessageServiceHttps implements YaloMessageService {
  final String _baseUrl;
  final String _channelId;
  final YaloMessageAuthService _authService;
  final Client _httpClient;
  final Logger log = Logger('YaloMessageServiceHttps');

  final int pollingRate = 1;
  final int pollingRateWindow = 5;
  bool polling = false;
  bool _paused = false;
  StreamController<PollMessageItem>? _controller;

  YaloMessageServiceHttps({
    required String baseUrl,
    required String channelId,
    required YaloMessageAuthService authService,
    Client? httpClient,
  }) : _baseUrl = baseUrl,
       _channelId = channelId,
       _authService = authService,
       _httpClient = httpClient ?? Client();

  @override
  Stream<PollMessageItem> messages() {
    final controller =
        _controller ??= StreamController<PollMessageItem>.broadcast();
    if (!polling) {
      _startPolling();
    }
    return controller.stream;
  }

  // Polls the adapter on a fixed cadence and forwards every fetched item to the
  // stream. Fetch failures are surfaced as stream errors so the repository can
  // react (e.g. clear the chat status).
  Future<void> _startPolling() async {
    polling = true;
    while (polling) {
      final int timestamp =
          DateTime.now().millisecondsSinceEpoch ~/ 1000 - pollingRateWindow;
      final Result<List<PollMessageItem>> result = await fetchMessages(
        timestamp,
      );
      switch (result) {
        case Ok():
          final sorted = result.result.toList()
            ..sort(
              (a, b) => a.date.toDateTime().compareTo(b.date.toDateTime()),
            );
          for (final item in sorted) {
            _controller?.add(item);
          }
          break;
        case Error():
          log.severe('Unable to fetch messages since $timestamp', result.error);
          _controller?.addError(result.error);
          break;
      }
      await Future.delayed(Duration(seconds: pollingRate));
    }
  }

  @override
  void pause() {
    log.info('Polling paused');
    _paused = true;
    polling = false;
  }

  @override
  void resume() {
    if (!_paused) {
      return;
    }
    log.info('Polling resumed');
    _paused = false;
    _startPolling();
  }

  @override
  void dispose() {
    polling = false;
    _paused = false;
    _controller?.close();
    _controller = null;
  }

  @override
  Future<Result<Unit>> sendSdkMessage(SdkMessage request) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final entry = (authResult as Ok<TokenEntry>).result;

    try {
      final url = 'https://$_baseUrl/v1/channels/inapp/inbound_messages';
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'content-type': 'application/json',
          'x-user-id': entry.userId,
          'x-channel-id': _channelId,
          'authorization': 'Bearer ${entry.accessToken}',
        },
        body: jsonEncode(request.toProto3Json()),
      );

      log.finest(url);
      log.finest({
        'content-type': 'application/json',
        'x-user-id': entry.userId,
        'x-channel-id': _channelId,
        'authorization': 'Bearer ${entry.accessToken}',
      });
      log.fine(jsonEncode(request.toProto3Json()));

      if (response.statusCode == 200) {
        log.fine(response.body);
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

  Future<Result<List<PollMessageItem>>> fetchMessages(int since) async {
    final authResult = await _authService.auth();
    if (authResult case Error(:final error)) {
      return Result.error(error);
    }
    final entry = (authResult as Ok<TokenEntry>).result;

    try {
      final url = 'https://$_baseUrl/v1/channels/inapp/messages';
      final queryParams = {'since': '$since'};
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await _httpClient.get(
        uri,
        headers: {
          'x-user-id': entry.userId,
          'x-channel-id': _channelId,
          'authorization': 'Bearer ${entry.accessToken}',
        },
      );
      log.finest(uri);
      log.finest({
        'x-user-id': entry.userId,
        'x-channel-id': _channelId,
        'authorization': 'Bearer ${entry.accessToken}',
      });
      log.finest(response.body);
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
