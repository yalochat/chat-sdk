// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/assistant_message.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/widgets.dart';

import 'user_message.dart';

class Message extends StatelessWidget {
  final ChatMessage messageToRender;
  const Message({super.key, required this.messageToRender});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: (messageToRender.role == MessageRole.user)
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (messageToRender.role == MessageRole.assistant)
          SizedBox(width: SdkConstants.rowItemSpace),
        switch (messageToRender.role) {
          MessageRole.user => UserMessage(message: messageToRender),
          MessageRole.assistant => AssistantMessage(message: messageToRender),
        },
        if (messageToRender.role == MessageRole.user)
          SizedBox(width: SdkConstants.rowItemSpace),
      ],
    );
  }
}
