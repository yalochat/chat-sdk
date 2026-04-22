// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/domain/models/command/chat_command.dart';
import 'package:logging/logging.dart';

class YaloChatClient {
  final String name;
  final String channelId;
  final String organizationId;
  final Map<ChatCommand, ChatCommandCallback> _commands = {};
  final Logger log = Logger('YaloChatClient');

  final String? userId;

  YaloChatClient({
    required this.name,
    required this.channelId,
    required this.organizationId,
    this.userId,
  });

  Map<ChatCommand, ChatCommandCallback> get commands =>
      Map.unmodifiable(_commands);

  void registerCommand(
    ChatCommand command,
    ChatCommandCallback callback,
  ) =>
      _commands[command] = callback;
}
