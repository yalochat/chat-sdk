// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:logging/logging.dart';

class Action {
  final String name;
  final void Function() action;

  Action({required this.name, required this.action});
}

class YaloChatClient {
  final String name;
  final String channelId;
  final String organizationId;
  final List<Action> actions;
  final Logger log = Logger('YaloChatClient');

  YaloChatClient({
    required this.name,
    required this.channelId,
    required this.organizationId,
  }) : actions = [];

  void registerAction(String actionName, void Function() action) =>
      actions.add(Action(name: actionName, action: action));
}
