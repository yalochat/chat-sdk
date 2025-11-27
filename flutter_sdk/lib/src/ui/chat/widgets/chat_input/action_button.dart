// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../theme/view_models/theme_cubit.dart';

enum ButtonAction { send, recordAudio }

class ActionButton extends StatelessWidget {
  const ActionButton({super.key});

  void _handleProcessMessage(ChatBloc chatBloc) {
    if (chatBloc.state.isUserRecordingAudio) {
      chatBloc.add(ChatStopRecording());
      chatBloc.add(ChatSendMessage());
    } else if (chatBloc.state.userMessage.isEmpty &&
        !chatBloc.state.isUserRecordingAudio) {
      chatBloc.add(ChatStartRecording());
    } else {
      chatBloc.add(ChatSendMessage());
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final chatBloc = context.read<ChatBloc>();
    return BlocSelector<ChatBloc, ChatState, (String, bool)>(
      selector: (state) => (state.userMessage, state.isUserRecordingAudio),
      builder: (context, state) {
        final (userMessage, isUserRecordingAudio) = state;
        var action = ButtonAction.send;
        if (userMessage.isEmpty && isUserRecordingAudio) {
          action = ButtonAction.send;
        } else if (userMessage.isEmpty && !isUserRecordingAudio) {
          action = ButtonAction.recordAudio;
        } else {
          action = ButtonAction.send;
        }
        return IconButton.filled(
          onPressed: () => _handleProcessMessage(chatBloc),
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: switch (action) {
              ButtonAction.send => chatThemeCubit.chatTheme.sendButtonIcon,
              ButtonAction.recordAudio =>
                chatThemeCubit.chatTheme.recordAudioIcon,
            },
          ),
          style: IconButton.styleFrom(
            backgroundColor: chatThemeCubit.chatTheme.sendButtonColor,
            foregroundColor: chatThemeCubit.chatTheme.sendButtonStyle,
            padding: EdgeInsets.all(SdkConstants.iconButtonPadding),
          ),
        );
      },
    );
  }
}
