// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_button.dart';
import 'attachment_button.dart';
import 'camera_button.dart';
import 'message_text_field.dart';

class ChatInputContainer extends StatelessWidget {
  final String hintText;
  final bool showCameraButton;
  final bool showAttachmentButton;
  const ChatInputContainer({
    super.key,
    this.hintText = "",
    this.showCameraButton = true,
    this.showAttachmentButton = true,
  });

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
