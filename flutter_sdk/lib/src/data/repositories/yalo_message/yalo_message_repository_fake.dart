// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:chat_flutter_sdk/domain/models/product/product.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_event/chat_event.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:clock/clock.dart';
import 'package:logging/logging.dart';

// Mocks a YaloMessageRepository just for testing/demo purposes
final class YaloMessageRepositoryFake implements YaloMessageRepository {
  final Clock _clock;
  final StreamController<ChatMessage> _messagesStreamController;
  final StreamController<ChatEvent> _typingEventsStreamController;
  MessageType prevMessageType = MessageType.text;
  final Logger log = Logger('ImageRepositoryLocal');

  YaloMessageRepositoryFake([
    StreamController<ChatMessage>? messageController,
    StreamController<ChatEvent>? typingEventsController,
    Clock? clock,
  ]) : _messagesStreamController = messageController ?? StreamController(),
       _typingEventsStreamController =
           typingEventsController ?? StreamController(),
       _clock = clock ?? Clock();

  @override
  Stream<ChatMessage> messages() =>
      _messagesStreamController.stream.asBroadcastStream();

  @override
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage) async {
    _typingEventsStreamController.sink.add(
      TypingStart(statusText: 'Writing message...'),
    );
    Future.delayed(Duration(milliseconds: 2000), () {
      _messagesStreamController.sink.add(
        ChatMessage.text(
          role: MessageRole.assistant,
          timestamp: _clock.now(),
          content: 'This is a mocked product assistant message 🤖',
          quickReplies: ['Quick!', 'Think!'],
        ),
      );
      _messagesStreamController.add(
        ChatMessage.product(
          role: MessageRole.assistant,
          products: [
            Product(
              sku: '123',
              name: 'Testing product',
              price: 300.0,
              salePrice: 270.0,
              unitName: '{amount, plural, one {box} other {boxes}}',
              subunitName: '{amount, plural, one {unit} other {units}}',
              subunits: 24,
              imagesUrl: [],
            ),
          ],
          timestamp: _clock.now(),
        ),
      );

      _messagesStreamController.sink.add(
        ChatMessage.text(
          role: MessageRole.assistant,
          timestamp: _clock.now(),
          content: 'This is a mocked product list assistant message 🤖',
        ),
      );

      _messagesStreamController.add(
        ChatMessage.product(
          role: MessageRole.assistant,
          products: [
            for (var i = 0; i < 5; i++)
              Product(
                sku: '$i',
                name: 'Testing product $i',
                price: 300.0 + i.toDouble(),
                salePrice: 270.0 + i.toDouble(),
                unitName: '{amount, plural, one {box} other {boxes}}',
                subunitName: '{amount, plural, one {unit} other {units}}',
                subunits: 5 + i.toDouble(),
                imagesUrl: [],
              ),
          ],
          timestamp: _clock.now(),
        ),
      );
      _messagesStreamController.sink.add(
        ChatMessage.text(
          role: MessageRole.assistant,
          timestamp: _clock.now(),
          content: 'This is a mocked carousel assistant message 🤖',
        ),
      );

      _messagesStreamController.add(
        ChatMessage.carousel(
          role: MessageRole.assistant,
          products: [
            for (var i = 0; i < 5; i++)
              Product(
                sku: '$i',
                name: 'Testing product carousel $i',
                price: 300.0 + i.toDouble(),
                salePrice: 270.0 + i.toDouble(),
                unitName: '{amount, plural, one {box} other {boxes}}',
                subunitName: '{amount, plural, one {unit} other {units}}',
                subunits: 5 + i.toDouble(),
                imagesUrl: [],
              ),
          ],
          timestamp: _clock.now(),
        ),
      );
      _typingEventsStreamController.sink.add(TypingStop());
    });
    return Result.ok(Unit());
  }

  @override
  Stream<ChatEvent> events() =>
      _typingEventsStreamController.stream.asBroadcastStream();

  @override
  void dispose() {
    _messagesStreamController.close();
    _typingEventsStreamController.close();
  }
}
