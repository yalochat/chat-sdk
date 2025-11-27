// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/waveform_recorder.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'action_button.dart';
import 'camera_button.dart';
import 'message_text_field.dart';

class ChatInput extends StatelessWidget {
  final String hintText;
  final bool showCameraButton;
  const ChatInput({
    super.key,
    this.hintText = '',
    this.showCameraButton = true,
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
                  constraints: BoxConstraints(
                    maxHeight: SdkConstants.maxChatInputSize,
                  ),
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
                  child: BlocSelector<ChatBloc, ChatState, bool>(
                    selector: (state) => state.isUserRecordingAudio,
                    builder: (context, isUserRecordingAudio) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(width: SdkConstants.rowItemSpace * 3),
                          Expanded(
                            child: isUserRecordingAudio
                                ? WaveformRecorder()
                                : MessageTextField(
                                    key: const Key('MessageTextField'),
                                    hintText: hintText,
                                  ),
                          ),
                          if (showCameraButton && !isUserRecordingAudio)
                            CameraButton(key: const Key('CameraButton')),
                        ],
                      );
                    },
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: SdkConstants.rowItemSpace,
                  right: SdkConstants.rowItemSpace,
                ),
                child: ActionButton(
                  key: const Key('ActionButton'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
