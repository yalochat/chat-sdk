// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../view_models/chat/chat_cubit.dart';
import '../../view_models/chat/chat_state.dart';
import '../../view_models/theme/theme_cubit.dart';

class ActionButton extends StatelessWidget {
  const ActionButton({super.key});

  void _handleSendMessage(BuildContext context) {
    final chatCubit = context.read<ChatCubit>();
    chatCubit.addMessage();
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeState = context.watch<ChatThemeCubit>();
    return BlocSelector<ChatCubit, ChatState, String>(
      selector: (state) => state.userMessage,
      builder: (context, userMessage) {
        return IconButton.filled(
          onPressed: () => _handleSendMessage(context),
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
            padding: EdgeInsets.all(12),
          ),
        );
      },
    );
  }
}
