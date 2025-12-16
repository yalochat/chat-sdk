// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/yalo_message/yalo_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:logging/logging.dart';

// Mocks a YaloMessageRepisotory just for testing/demo purposes
final class YaloMessageRepositoryFake extends YaloMessageRepository {
  final StreamController<ChatMessage> _streamController;
  final Logger log = Logger('ImageRepositoryLocal');

  YaloMessageRepositoryFake([StreamController<ChatMessage>? controller])
    : _streamController = controller ?? StreamController();

  @override
  Stream<ChatMessage> messages() => _streamController.stream;

  @override
  Future<Result<Unit>> sendMessage(ChatMessage chatMessage) {
    throw UnimplementedError();
  }
}
