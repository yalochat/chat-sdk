// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:http/http.dart';

class _TokenCache {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  _TokenCache({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });
}

class YaloMessageAuthServiceRemote implements YaloMessageAuthService {
  final String _baseUrl;
  final String _channelId;
  final String _organizationId;
  final Client _httpClient;

  _TokenCache? _cache;

  YaloMessageAuthServiceRemote({
    required String baseUrl,
    required String channelId,
    required String organizationId,
    Client? httpClient,
  })  : _baseUrl = baseUrl,
        _channelId = channelId,
        _organizationId = organizationId,
        _httpClient = httpClient ?? Client();

  @override
  Future<Result<String>> auth() async {
    if (_cache != null && DateTime.now().isBefore(_cache!.expiresAt)) {
      return Result.ok(_cache!.accessToken);
    }

    if (_cache?.refreshToken != null) {
      return _refresh(_cache!.refreshToken);
    }

    return _fetchToken();
  }

  Future<Result<String>> _fetchToken() async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_type': 'anonymous',
          'channel_id': _channelId,
          'organization_id': _organizationId,
          'timestamp':
              DateTime.now().millisecondsSinceEpoch ~/ 1000,
        }),
      );

      if (response.statusCode != 200) {
        return Result.error(
          Exception('Auth failed: ${response.statusCode}'),
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _storeCache(data);
      return Result.ok(data['access_token'] as String);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<String>> _refresh(String refreshToken) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/oauth/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        },
      );

      if (response.statusCode != 200) {
        _cache = null;
        return Result.error(
          Exception('Refresh failed: ${response.statusCode}'),
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _storeCache(data);
      return Result.ok(data['access_token'] as String);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  void _storeCache(Map<String, dynamic> data) {
    _cache = _TokenCache(
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
      expiresAt: DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      ),
    );
  }
}
