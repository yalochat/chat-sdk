// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserMessage extends StatelessWidget {
  final String content;
  const UserMessage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: EdgeInsets.all(SdkConstants.messagePadding),
          decoration: BoxDecoration(
            color: chatThemeCubit.chatTheme.userMessageColor,
            borderRadius: BorderRadius.circular(SdkConstants.messageBorderRadius),
          ),
          child: SelectableText(
            content,
            style: chatThemeCubit.chatTheme.userMessageTextStyle,
          ),
        ),
        SizedBox(width: SdkConstants.rowItemSpace),
      ],
    );
  }
}
