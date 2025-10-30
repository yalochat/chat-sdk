// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/widgets/chat_input/action_button.dart';
import 'package:chat_flutter_sdk/src/ui/widgets/chat_input/attachment_button.dart';
import 'package:chat_flutter_sdk/src/ui/widgets/chat_input/camera_button.dart';
import 'package:chat_flutter_sdk/src/ui/widgets/chat_input/message_text_field.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../view_models/theme/theme_cubit.dart';

class ChatInputContainer extends StatelessWidget {
  final String hintText;
  const ChatInputContainer({super.key, this.hintText = ""});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (context, chatTheme) {
        return Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: chatTheme.backgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AttachmentButton(),
              Expanded(child: MessageTextField(hintText: hintText)),
              CameraButton(),
              ActionButton(),
            ],
          ),
        );
      },
    );
  }
}
