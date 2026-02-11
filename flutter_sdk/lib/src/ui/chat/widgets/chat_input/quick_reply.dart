// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:chat_flutter_sdk/yalo_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QuickReply extends StatelessWidget {
  final String text;
  const QuickReply({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<MessagesBloc>();
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (BuildContext context, ChatTheme theme) {
        return Container(
          decoration: BoxDecoration(
            color: theme.quickReplyColor,
            border: BoxBorder.all(color: theme.quickReplyBorderColor),
            borderRadius: BorderRadius.circular(SdkConstants.inputBorderRadius),
          ),
          child: TextButton(
            child: Text(text, style: theme.quickReplyStyle),
            onPressed: () {
              chatBloc.add(ChatSendTextMessage(text: text));
              chatBloc.add(ChatClearQuickReplies());
            },
          ),
        );
      },
    );
  }
}
