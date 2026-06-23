// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:convert';

import 'package:logging/logging.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri uri);

class YaloMessageServiceWebSocket implements YaloMessageService {
  static const Duration _initialBackoff = Duration(seconds: 1);
  static const Duration _maxBackoff = Duration(seconds: 30);
  static const Duration _ackTimeout = Duration(seconds: 10);

  final String _wsUrl;
  final YaloMessageAuthService _authService;
  final WebSocketChannelFactory _channelFactory;
  final Logger log = Logger('YaloMessageServiceWebSocket');

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  StreamController<PollMessageItem>? _controller;
  Timer? _reconnectTimer;
  Timer? _ackTimer;
  int _reconnectAttempt = 0;
  bool _running = false;
  bool _paused = false;
  bool _connectionAcked = false;
  final List<String> _pendingFrames = [];

  YaloMessageServiceWebSocket({
    required String baseUrl,
    required YaloMessageAuthService authService,
    WebSocketChannelFactory? channelFactory,
  }) : _wsUrl = 'wss://$baseUrl/websocket/v1/connect/inapp',
       _authService = authService,
       _channelFactory =
           channelFactory ?? ((uri) => IOWebSocketChannel.connect(uri));

  @override
  Stream<PollMessageItem> messages() {
    final controller = _controller ??=
        StreamController<PollMessageItem>.broadcast();
    if (!_running) {
      _running = true;
      _connect();
    }
    return controller.stream;
  }

  @override
  void pause() {
    if (!_running) {
      return;
    }
    log.info('Connection paused');
    _running = false;
    _paused = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _clearAckTimer();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _connectionAcked = false;
  }

  @override
  void resume() {
    if (!_paused || _controller == null) {
      return;
    }
    log.info('Connection resumed');
    _paused = false;
    _running = true;
    _reconnectAttempt = 0;
    _connect();
  }

  @override
  Future<Result<Unit>> sendSdkMessage(SdkMessage message) async {
    if (!_running) {
      return Result.error(Exception('WebSocket is not connected'));
    }
    final String frame;
    try {
      frame = jsonEncode(message.toProto3Json());
    } on Exception catch (e) {
      return Result.error(e);
    }
    final channel = _channel;
    if (!_connectionAcked || channel == null) {
      _pendingFrames.add(frame);
      return Result.ok(Unit());
    }
    try {
      channel.sink.add(frame);
      return Result.ok(Unit());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  void dispose() {
    _running = false;
    _paused = false;
    _reconnectAttempt = 0;
    _connectionAcked = false;
    _pendingFrames.clear();
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _clearAckTimer();
    _subscription?.cancel();
    _subscription = null;
    _channel?.sink.close();
    _channel = null;
    _controller?.close();
    _controller = null;
  }

  void _clearAckTimer() {
    _ackTimer?.cancel();
    _ackTimer = null;
  }

  void _flushPending() {
    final channel = _channel;
    if (channel == null) {
      return;
    }
    final pending = List<String>.from(_pendingFrames);
    _pendingFrames.clear();
    for (final frame in pending) {
      try {
        channel.sink.add(frame);
      } on Exception {
        // The caller already received Ok at enqueue time.
      }
    }
  }

  Future<void> _connect() async {
    if (!_running || _channel != null) {
      return;
    }

    final authResult = await _authService.auth();
    if (authResult case Error()) {
      log.warning('Auth failed, scheduling reconnect');
      _scheduleReconnect();
      return;
    }
    if (!_running) {
      return;
    }
    final entry = (authResult as Ok<TokenEntry>).result;

    final WebSocketChannel channel;
    try {
      final uri = Uri.parse(
        '$_wsUrl?token=${Uri.encodeComponent(entry.accessToken)}',
      );
      channel = _channelFactory(uri);
    } on Exception catch (e) {
      log.warning('Failed to open websocket', e);
      _scheduleReconnect();
      return;
    }

    _channel = channel;
    _reconnectAttempt = 0;
    _ackTimer = Timer(_ackTimeout, () {
      _ackTimer = null;
      channel.sink.close();
    });

    _subscription = channel.stream.listen(
      _onFrame,
      onDone: _onDone,
      onError: _onError,
      cancelOnError: true,
    );
  }

  void _onFrame(dynamic data) {
    if (data is! String) {
      return;
    }
    final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) {
        return;
      }
      json = decoded;
    } on FormatException {
      return;
    }
    try {
      if (!_connectionAcked) {
        final ack = ConnectionAck.create()
          ..mergeFromProto3Json(json, ignoreUnknownFields: true);
        if (ack.type == ConnectionAckType.CONNECTION_ACK_TYPE_CONNECTION_ACK) {
          _connectionAcked = true;
          _clearAckTimer();
          _flushPending();
        }
        return;
      }
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
    _connectionAcked = false;
    _clearAckTimer();
    if (_running) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_running || _reconnectTimer != null) {
      return;
    }
    final ms = (_initialBackoff.inMilliseconds * (1 << _reconnectAttempt))
        .clamp(_initialBackoff.inMilliseconds, _maxBackoff.inMilliseconds);
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(milliseconds: ms), () {
      _reconnectTimer = null;
      _connect();
    });
  }
}
