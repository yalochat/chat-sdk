// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_button.dart';
import 'attachment_button.dart';
import 'camera_button.dart';
import 'message_text_field.dart';

class ChatInput extends StatelessWidget {
  final String hintText;
  final bool showCameraButton;
  final bool showAttachmentButton;
  const ChatInput({
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
          padding: EdgeInsets.all(SdkConstants.inputPadding),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: SdkConstants.rowItemSpace),
                  decoration: BoxDecoration(
                    color: chatTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(
                      SdkConstants.inputBorderRadius,
                    ),
                    border: Border.all(
                      width: 1,
                      color: chatTheme.inputTextFieldBorderColor,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(width: SdkConstants.rowItemSpace * 3),
                      Expanded(child: MessageTextField(hintText: hintText)),
                      CameraButton(),
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SdkConstants.rowItemSpace,
                  right: SdkConstants.rowItemSpace,
                ),
                child: ActionButton(),
              ),
            ],
          ),
        );
      },
    );
  }
}
