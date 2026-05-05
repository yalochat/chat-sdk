// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';

typedef WebSocketChannelFactory =
    WebSocketChannel Function(Uri uri, {Duration? pingInterval});

class YaloMessageServiceWebSocket {
  static const Duration _initialBackoff = Duration(seconds: 1);
  static const Duration _maxBackoff = Duration(seconds: 30);
  static const Duration _defaultPingInterval = Duration(seconds: 20);

  final String _wsUrl;
  final YaloMessageAuthService _authService;
  final WebSocketChannelFactory _channelFactory;
  final Duration _pingInterval;
  final Logger log = Logger('YaloMessageServiceWebSocket');

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  StreamController<PollMessageItem>? _controller;
  final List<String> _pendingFrames = [];
  Timer? _reconnectTimer;
  int _reconnectAttempt = 0;
  bool _running = false;

  YaloMessageServiceWebSocket({
    required String baseUrl,
    required YaloMessageAuthService authService,
    WebSocketChannelFactory? channelFactory,
    Duration pingInterval = _defaultPingInterval,
  }) : _wsUrl = 'wss://$baseUrl/websocket/v1/connect/inapp',
       _authService = authService,
       _channelFactory =
           channelFactory ??
           ((uri, {pingInterval}) =>
               IOWebSocketChannel.connect(uri, pingInterval: pingInterval)),
       _pingInterval = pingInterval;

  Stream<PollMessageItem> messages() {
    final controller =
        _controller ??= StreamController<PollMessageItem>.broadcast();
    if (!_running) {
      _running = true;
      _connect();
    }
    return controller.stream;
  }

  Future<Result<Unit>> sendSdkMessage(SdkMessage message) async {
    try {
      final frame = jsonEncode(message.toProto3Json());
      final channel = _channel;
      if (channel != null) {
        channel.sink.add(frame);
      } else {
        _pendingFrames.add(frame);
        if (!_running) {
          _running = true;
          _connect();
        }
      }
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  void dispose() {
    _running = false;
    _pendingFrames.clear();
    _reconnectAttempt = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _controller?.close();
    _controller = null;
  }

  Future<void> _connect() async {
    if (!_running || _channel != null) return;

    final authResult = await _authService.auth();
    if (authResult case Error()) {
      log.warning('Auth failed, scheduling reconnect');
      _scheduleReconnect();
      return;
    }
    if (!_running) return;
    final entry = (authResult as Ok<TokenEntry>).result;

    final WebSocketChannel channel;
    try {
      final uri = Uri.parse(
        '$_wsUrl?token=${Uri.encodeComponent(entry.accessToken)}',
      );
      channel = _channelFactory(uri, pingInterval: _pingInterval);
    } on Exception catch (e) {
      log.warning('Failed to open websocket', e);
      _scheduleReconnect();
      return;
    }

    _channel = channel;
    _reconnectAttempt = 0;

    final queued = List<String>.from(_pendingFrames);
    _pendingFrames.clear();
    for (final frame in queued) {
      channel.sink.add(frame);
    }

    _subscription = channel.stream.listen(
      _onFrame,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: true,
    );
  }

  void _onFrame(dynamic data) {
    if (data is! String) return;
    try {
      final json = jsonDecode(data);
      if (json is! Map<String, dynamic>) return;
      final item = PollMessageItem.create()..mergeFromProto3Json(json);
      _controller?.add(item);
    } on Exception catch (e) {
      log.fine('Ignoring malformed websocket frame', e);
    }
  }

  void _onError(Object error) {
    log.warning('WebSocket error', error);
    _handleClose();
  }

  void _onDone() {
    _handleClose();
  }

  void _handleClose() {
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    if (_running) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (!_running || _reconnectTimer != null) return;
    final ms = (_initialBackoff.inMilliseconds * (1 << _reconnectAttempt))
        .clamp(_initialBackoff.inMilliseconds, _maxBackoff.inMilliseconds);
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(milliseconds: ms), () {
      _reconnectTimer = null;
      _connect();
    });
  }
}
