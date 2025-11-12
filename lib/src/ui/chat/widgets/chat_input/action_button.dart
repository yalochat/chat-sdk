// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/view_models/theme_cubit.dart';

class ActionButton extends StatelessWidget {
  final String userMessage;
  final VoidCallback onPressed;
  const ActionButton({
    super.key,
    required this.userMessage,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final chatThemeState = context.watch<ChatThemeCubit>();

    return IconButton.filled(
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: userMessage.isNotEmpty
            ? chatThemeState.chatTheme.sendButtonIcon
            : chatThemeState.chatTheme.recordAudioIcon,
      ),
      style: IconButton.styleFrom(
        backgroundColor: chatThemeState.chatTheme.sendButtonColor,
        foregroundColor: chatThemeState.chatTheme.sendButtonStyle,
        padding: EdgeInsets.all(SdkConstants.iconButtonPadding),
      ),
    );
  }
}
