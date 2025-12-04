// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/waveform_painter.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserVoiceMessage extends StatelessWidget {
  final ChatMessage message;
  const UserVoiceMessage({super.key, required this.message});

  void _handlePlayMessage(AudioBloc bloc) {
    if (bloc.state.playingMessage != null &&
        bloc.state.playingMessage!.id == message.id) {
      bloc.add(AudioStop());
    } else {
      bloc.add(AudioPlay(message: message));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<AudioBloc>();
    final chatThemeCubit = context.watch<ChatThemeCubit>();
    assert(
      message.amplitudes != null && message.amplitudes!.isNotEmpty,
      'amplitudes must be defined in order to not show an empty message',
    );

    assert(
      message.fileName != null && message.type == MessageType.voice,
      'message should contain a file name for the audio',
    );

    return Row(
      children: [
        BlocSelector<AudioBloc, AudioState, ChatMessage?>(
          selector: (state) => state.playingMessage,
          builder: (context, playingMessage) {
            return IconButton(
              key: const Key('voice-message-play-icon'),
              onPressed: () {
                _handlePlayMessage(chatBloc);
              },
              icon: playingMessage != null && playingMessage.id == message.id
                  ? chatThemeCubit.chatTheme.pauseAudioIcon
                  : chatThemeCubit.chatTheme.playAudioIcon,
            );
          },
        ),
        CustomPaint(
          painter: WaveformPainter(
            message.amplitudes!,
            chatThemeCubit.state.waveColor,
          ),
          child: SizedBox(
            width: SdkConstants.messageWaveformWidth,
            height: SdkConstants.messageWaveformHeight,
          ),
        ),
      ],
    );
  }
}
