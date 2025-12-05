// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum ButtonAction { send, recordAudio }

class ActionButton extends StatelessWidget {
  const ActionButton({super.key});

  void _handleProcessMessage(MessagesBloc messagesBloc, AudioBloc audioBloc) {
    bool isUserRecordingAudio = audioBloc.state.isUserRecordingAudio;
    String userMessage = messagesBloc.state.userMessage;
    if (userMessage.isEmpty && !isUserRecordingAudio) {
      audioBloc.add(AudioStartRecording());
    } else {
      audioBloc.add(AudioStopRecording());
      if (isUserRecordingAudio) {
        messagesBloc.add(
          ChatSendVoiceMessage(
            amplitudes: audioBloc.state.amplitudesFilePreview,
            fileName: audioBloc.state.audioFileName,
            duration: audioBloc.state.millisecondsRecording,
          ),
        );
      } else {
        messagesBloc.add(ChatSendTextMessage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    final messageBloc = context.read<MessagesBloc>();
    final audioBloc = context.read<AudioBloc>();
    return BlocSelector<AudioBloc, AudioState, bool>(
      selector: (state) => state.isUserRecordingAudio,
      builder: (context, isUserRecordingAudio) {
        return BlocSelector<MessagesBloc, MessagesState, String>(
          selector: (state) => state.userMessage,
          builder: (context, userMessage) {
            var action = ButtonAction.send;
            if (userMessage.isEmpty && isUserRecordingAudio) {
              action = ButtonAction.send;
            } else if (userMessage.isEmpty && !isUserRecordingAudio) {
              action = ButtonAction.recordAudio;
            } else {
              action = ButtonAction.send;
            }
            return IconButton.filled(
              onPressed: () => _handleProcessMessage(messageBloc, audioBloc),
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
      },
    );
  }
}
