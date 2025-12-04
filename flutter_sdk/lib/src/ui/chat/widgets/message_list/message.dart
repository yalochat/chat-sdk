// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:flutter/widgets.dart';

import 'user_message.dart';

class Message extends StatelessWidget {
  final ChatMessage messageToRender;
  const Message({super.key, required this.messageToRender});

  @override
  Widget build(BuildContext context) {
    if (messageToRender.role == MessageRole.user) {
      return UserMessage(message: messageToRender);
    } else {
      throw UnimplementedError();
    }
  }
}
