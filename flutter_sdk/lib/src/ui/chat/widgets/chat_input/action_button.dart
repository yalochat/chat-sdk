// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_state.dart';
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

  void _handleProcessMessage(
    MessagesBloc messagesBloc,
    AudioBloc audioBloc,
    ImageBloc imageBloc,
  ) {
    bool isUserRecordingAudio = audioBloc.state.isUserRecordingAudio;
    String userMessage = messagesBloc.state.userMessage;
    ImageData? pickedImage = imageBloc.state.pickedImage;
    if (userMessage.isEmpty && !isUserRecordingAudio && pickedImage == null) {
      audioBloc.add(AudioStartRecording());
    } else if (pickedImage != null) {
      messagesBloc.add(
        ChatSendImageMessage(imageData: pickedImage, text: userMessage),
      );
      imageBloc.add(ImageHidePreview());
    } else {
      audioBloc.add(AudioStopRecording());
      if (isUserRecordingAudio) {
        messagesBloc.add(
          ChatSendVoiceMessage(audioData: audioBloc.state.audioData),
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
    final imageBloc = context.read<ImageBloc>();
    return BlocSelector<AudioBloc, AudioState, bool>(
      selector: (state) => state.isUserRecordingAudio,
      builder: (context, isUserRecordingAudio) {
        return BlocSelector<ImageBloc, ImageState, ImageData?>(
          selector: (state) => state.pickedImage,
          builder: (context, pickedImage) {
            return BlocSelector<MessagesBloc, MessagesState, String>(
              selector: (state) => state.userMessage,
              builder: (context, userMessage) {
                var action = ButtonAction.send;
                if (userMessage.isEmpty && isUserRecordingAudio ||
                    pickedImage != null) {
                  action = ButtonAction.send;
                } else if (userMessage.isEmpty &&
                    !isUserRecordingAudio &&
                    pickedImage == null) {
                  action = ButtonAction.recordAudio;
                } else {
                  action = ButtonAction.send;
                }
                return IconButton.filled(
                  onPressed: () =>
                      _handleProcessMessage(messageBloc, audioBloc, imageBloc),
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                    child: switch (action) {
                      ButtonAction.send =>
                        chatThemeCubit.chatTheme.sendButtonIcon,
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
      },
    );
  }
}
