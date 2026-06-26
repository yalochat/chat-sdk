// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:yalo_chat_flutter_sdk/domain/models/command/chat_command.dart';
import 'package:yalo_chat_flutter_sdk/domain/models/command/custom_command.dart';
import 'package:logging/logging.dart';

class YaloChatClient {
  final String name;
  final String channelId;
  final String organizationId;
  final Map<ChatCommand, ChatCommandCallback> _commands = {};
  final Map<String, CustomCommandCallback> _customCommands = {};
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

  void registerCommand(ChatCommand command, ChatCommandCallback callback) =>
      _commands[command] = callback;

  Map<String, CustomCommandCallback> get customCommands =>
      Map.unmodifiable(_customCommands);

  // Registers a handler for a channel-to-client custom command. When the
  // channel sends a custom command request whose command_id matches, the
  // handler runs with the request payload and its result is sent back as the
  // response.
  void onCommand(String commandId, CustomCommandCallback handler) =>
      _customCommands[commandId] = handler;
}
