// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:convert';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

class YaloMessageAuthServiceRemote implements YaloMessageAuthService {
  static const _keyAccessToken = 'yalo_auth_access_token';
  static const _keyRefreshToken = 'yalo_auth_refresh_token';
  static const _keyExpiresAt = 'yalo_auth_expires_at';

  final String _baseUrl;
  final String _channelId;
  final String _organizationId;
  final Client _httpClient;
  final FlutterSecureStorage _storage;

  TokenEntry? _cache;

  YaloMessageAuthServiceRemote({
    required String baseUrl,
    required String channelId,
    required String organizationId,
    required FlutterSecureStorage storage,
    Client? httpClient,
  }) : _baseUrl = baseUrl,
       _channelId = channelId,
       _organizationId = organizationId,
       _storage = storage,
       _httpClient = httpClient ?? Client();

  @override
  Future<Result<TokenEntry>> auth() async {
    if (_cache != null && DateTime.now().isBefore(_cache!.expiresAt)) {
      return Result.ok(_cache!);
    }

    if (_cache == null) {
      await _loadFromStorage();
    }

    if (_cache != null && DateTime.now().isBefore(_cache!.expiresAt)) {
      return Result.ok(_cache!);
    }

    if (_cache?.refreshToken != null) {
      return _refresh(_cache!.refreshToken);
    }
    return _fetchToken();
  }

  Future<void> _loadFromStorage() async {
    final accessToken = await _storage.read(key: _keyAccessToken);
    final refreshToken = await _storage.read(key: _keyRefreshToken);
    final expiresAtRaw = await _storage.read(key: _keyExpiresAt);

    if (accessToken == null || refreshToken == null || expiresAtRaw == null) {
      return;
    }

    final expiresAt = DateTime.tryParse(expiresAtRaw);
    if (expiresAt == null) return;

    _cache = TokenEntry(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      userId: _decodeUserId(accessToken),
    );
  }

  Future<void> _saveToStorage() async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: _cache!.accessToken),
      _storage.write(key: _keyRefreshToken, value: _cache!.refreshToken),
      _storage.write(
        key: _keyExpiresAt,
        value: _cache!.expiresAt.toIso8601String(),
      ),
    ]);
  }

  Future<void> _clearStorage() async {
    await Future.wait([
      _storage.delete(key: _keyAccessToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyExpiresAt),
    ]);
  }

  Future<Result<TokenEntry>> _fetchToken() async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_type': 'anonymous',
          'channel_id': _channelId,
          'organization_id': _organizationId,
          'timestamp': Timestamp.fromDateTime(DateTime.now()).seconds.toInt(),
        }),
      );

      if (response.statusCode != 200) {
        return Result.error(Exception('Auth failed: ${response.statusCode}'));
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storeCache(data);
      return Result.ok(_cache!);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<Result<TokenEntry>> _refresh(String refreshToken) async {
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
        await _clearStorage();
        return Result.error(
          Exception('Refresh failed: ${response.statusCode}'),
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      await _storeCache(data);
      return Result.ok(_cache!);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  Future<void> _storeCache(Map<String, dynamic> data) async {
    final accessToken = data['access_token'] as String;
    _cache = TokenEntry(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String,
      expiresAt: DateTime.now().add(
        Duration(seconds: data['expires_in'] as int),
      ),
      userId: _decodeUserId(accessToken),
    );
    await _saveToStorage();
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
