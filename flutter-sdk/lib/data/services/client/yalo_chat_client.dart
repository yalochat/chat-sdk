// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:logging/logging.dart';

class YaloChatClient {
  final String name;
  final String channelId;
  final String organizationId;
  final Map<String, Function> _commands = {};
  final Logger log = Logger('YaloChatClient');

  final String? userId;

  YaloChatClient({
    required this.name,
    required this.channelId,
    required this.organizationId,
    this.userId,
  });

  Map<String, Function> get commands => Map.unmodifiable(_commands);

  // Registers a handler the chat can invoke on the host app, keyed by command
  // id. Client -> channel command ids (the ChatCommand constants) take a
  // ChatCommandCallback and run instead of the built-in remote call. Any other
  // id takes a CustomCommandCallback that answers the matching channel custom
  // command request, and its result is sent back as the response.
  void registerCommand(String command, Function handler) =>
      _commands[command] = handler;
}
