// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yalo_chat_flutter_sdk/src/common/result.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message/yalo_message_service_websocket.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/token_entry.dart';
import 'package:yalo_chat_flutter_sdk/src/data/services/yalo_message_auth/yalo_message_auth_service.dart';
import 'package:yalo_chat_flutter_sdk/src/domain/models/events/external_channel/in_app/sdk/sdk_message.pb.dart';

class MockYaloMessageAuthService extends Mock
    implements YaloMessageAuthService {}

class _FakeSink implements WebSocketSink {
  final List<dynamic> sent = [];
  bool closed = false;

  @override
  void add(dynamic data) => sent.add(data);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closed = true;
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<dynamic> addStream(Stream stream) async {}

  @override
  Future<dynamic> get done => Future.value();
}

class _FakeChannel implements WebSocketChannel {
  _FakeChannel(this.uri);

  final Uri uri;
  final StreamController<dynamic> _incoming = StreamController<dynamic>();
  final _FakeSink _sink = _FakeSink();

  void emit(String frame) => _incoming.add(frame);
  void emitError(Object error) => _incoming.addError(error);
  Future<void> closeStream() => _incoming.close();

  @override
  WebSocketSink get sink => _sink;

  @override
  Stream<dynamic> get stream => _incoming.stream;

  List<dynamic> get sent => _sink.sent;
  bool get sinkClosed => _sink.closed;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

TokenEntry _tokenEntry(String token) => TokenEntry(
  accessToken: token,
  refreshToken: 'refresh',
  expiresAt: DateTime.now().add(const Duration(hours: 1)),
  userId: 'user-1',
);

SdkMessage _textMessage(String text) => SdkMessage(
  correlationId: 'cid-1',
  textMessageRequest: TextMessageRequest(
    content: TextMessage(
      text: text,
      role: MessageRole.MESSAGE_ROLE_USER,
      status: MessageStatus.MESSAGE_STATUS_SENT,
    ),
  ),
);

const _incomingFrame = '''
{
  "id": "3a73bc83-b4da-4fef-a83e-21310edc0283",
  "message": {
    "timestamp": "2026-03-26T16:51:35.766Z",
    "textMessageRequest": {
      "content": {"text": "Hello from server"}
    }
  },
  "date": "2026-03-26T16:51:36Z",
  "user_id": "c2420cb3-08eb-4ca4-b299-7c04c195f413",
  "status": "IN_DELIVERY"
}
''';

const _ackFrame = '''
{
  "type": "CONNECTION_ACK_TYPE_CONNECTION_ACK",
  "connectionId": "conn-1",
  "timestamp": "2026-03-26T16:51:30Z"
}
''';

void main() {
  group('YaloMessageServiceWebSocket', () {
    late MockYaloMessageAuthService auth;
    late List<_FakeChannel> channels;
    late YaloMessageServiceWebSocket service;

    WebSocketChannel factory(Uri uri) {
      final ch = _FakeChannel(uri);
      channels.add(ch);
      return ch;
    }

    setUp(() {
      auth = MockYaloMessageAuthService();
      channels = [];
      service = YaloMessageServiceWebSocket(
        baseUrl: 'api.example.com',
        authService: auth,
        channelFactory: factory,
      );
    });

    tearDown(() => service.dispose());

    test('opens websocket with token query parameter', () async {
      when(
        () => auth.auth(),
      ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

      service.messages().listen((_) {});
      await Future.delayed(Duration.zero);

      expect(channels, hasLength(1));
      expect(
        channels.single.uri.toString(),
        equals(
          'wss://api.example.com/websocket/v1/connect/inapp?token=abc',
        ),
      );
    });

    test('encodes the access token for URL safety', () async {
      when(
        () => auth.auth(),
      ).thenAnswer((_) async => Result.ok(_tokenEntry('a b/c?d=1')));

      service.messages().listen((_) {});
      await Future.delayed(Duration.zero);

      expect(
        channels.single.uri.queryParameters['token'],
        equals('a b/c?d=1'),
      );
    });

    test('emits decoded PollMessageItem for incoming text frames', () async {
      when(
        () => auth.auth(),
      ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

      final received = <PollMessageItem>[];
      service.messages().listen(received.add);
      await Future.delayed(Duration.zero);

      channels.single.emit(_ackFrame);
      channels.single.emit(_incomingFrame);
      await Future.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(
        received.single.message.textMessageRequest.content.text,
        equals('Hello from server'),
      );
    });

    test('drops PollMessageItem frames that arrive before the connection ack',
        () async {
      when(
        () => auth.auth(),
      ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

      final received = <PollMessageItem>[];
      service.messages().listen(received.add);
      await Future.delayed(Duration.zero);

      channels.single.emit(_incomingFrame);
      await Future.delayed(Duration.zero);

      expect(received, isEmpty);
    });

    test('ignores malformed frames without crashing', () async {
      when(
        () => auth.auth(),
      ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

      final received = <PollMessageItem>[];
      service.messages().listen(received.add);
      await Future.delayed(Duration.zero);

      channels.single.emit(_ackFrame);
      channels.single.emit('not json');
      channels.single.emit('"a string, not an object"');
      channels.single.emit(_incomingFrame);
      await Future.delayed(Duration.zero);

      expect(received, hasLength(1));
    });

    test('buffers frames until the connection ack arrives', () async {
      when(
        () => auth.auth(),
      ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

      service.messages().listen((_) {});
      await Future.delayed(Duration.zero);

      final beforeAck = await service.sendSdkMessage(_textMessage('one'));
      expect(beforeAck, isA<Ok<Unit>>());
      expect(channels.single.sent, isEmpty);

      channels.single.emit(_ackFrame);
      await Future.delayed(Duration.zero);

      final afterAck = await service.sendSdkMessage(_textMessage('two'));
      expect(afterAck, isA<Ok<Unit>>());
      expect(channels.single.sent, hasLength(2));
      final firstBody =
          jsonDecode(channels.single.sent[0] as String)
              as Map<String, dynamic>;
      final secondBody =
          jsonDecode(channels.single.sent[1] as String)
              as Map<String, dynamic>;
      expect(
        firstBody['textMessageRequest']['content']['text'],
        equals('one'),
      );
      expect(
        secondBody['textMessageRequest']['content']['text'],
        equals('two'),
      );
    });

    test('buffers frames again after a close and flushes them on the next ack',
        () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        channels.single.emit(_ackFrame);
        async.flushMicrotasks();

        channels.single.closeStream();
        async.flushMicrotasks();

        service.sendSdkMessage(_textMessage('after-close'));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(channels, hasLength(2));
        expect(channels.last.sent, isEmpty);

        channels.last.emit(_ackFrame);
        async.flushMicrotasks();

        expect(channels.last.sent, hasLength(1));
        final body =
            jsonDecode(channels.last.sent.single as String)
                as Map<String, dynamic>;
        expect(
          body['textMessageRequest']['content']['text'],
          equals('after-close'),
        );
      });
    });

    test(
      'sendSdkMessage returns Error when called before any listener subscribes',
      () async {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        final result = await service.sendSdkMessage(_textMessage('hi'));
        await Future.delayed(Duration.zero);

        expect(result, isA<Error<Unit>>());
        expect(channels, isEmpty);
      },
    );

    test('reconnects with exponential backoff after the socket closes',
        () async {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        expect(channels, hasLength(1));

        channels.first.closeStream();
        async.flushMicrotasks();

        async.elapse(const Duration(milliseconds: 999));
        expect(channels, hasLength(1));

        async.elapse(const Duration(milliseconds: 2));
        async.flushMicrotasks();
        expect(channels, hasLength(2));

        channels.last.closeStream();
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        async.flushMicrotasks();
        expect(channels, hasLength(3));
      });
    });

    test('schedules a reconnect when auth fails', () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.error(Exception('unauthorized')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        expect(channels, isEmpty);

        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(verify(() => auth.auth()).callCount, greaterThanOrEqualTo(2));
      });
    });

    test('schedules a reconnect when the stream errors', () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        expect(channels, hasLength(1));

        channels.first.emitError(Exception('boom'));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(channels, hasLength(2));
      });
    });

    test('dispose stops reconnects and closes the active socket', () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        final firstChannel = channels.first;

        service.dispose();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(firstChannel.sinkClosed, isTrue);
        expect(channels, hasLength(1));
      });
    });

    test('pause closes the socket without reconnecting', () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        final firstChannel = channels.first;

        service.pause();
        async.elapse(const Duration(seconds: 5));
        async.flushMicrotasks();

        expect(firstChannel.sinkClosed, isTrue);
        expect(channels, hasLength(1));
      });
    });

    test('resume reconnects after a pause', () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();
        expect(channels, hasLength(1));

        service.pause();
        service.resume();
        async.flushMicrotasks();

        expect(channels, hasLength(2));
      });
    });

    test('resume is a no-op when not paused', () {
      fakeAsync((async) {
        when(
          () => auth.auth(),
        ).thenAnswer((_) async => Result.ok(_tokenEntry('abc')));

        service.messages().listen((_) {});
        async.flushMicrotasks();

        service.resume();
        async.flushMicrotasks();

        expect(channels, hasLength(1));
      });
    });
  });
}
