// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'waveform_painter.dart';

// Widget that displays a waveform recorder in a container
class WaveformRecorder extends StatelessWidget {
  const WaveformRecorder({super.key});

  void _handleOnCancel(ChatBloc bloc) {
    bloc.add(ChatStopRecording());
  }

  @override
  Widget build(BuildContext context) {
    final chatBloc = context.read<ChatBloc>();
    return BlocBuilder<ChatThemeCubit, ChatTheme>(
      builder: (context, chatTheme) {
        return BlocSelector<ChatBloc, ChatState, (List<double>, int)>(
          selector: (state) => (state.amplitudes, state.millisecondsRecording),
          builder: (context, state) {
            final (amplitudes, millisecondsRecording) = state;
            final minutes = millisecondsRecording ~/ 1000 ~/ 60;
            final seconds =
                (millisecondsRecording - (minutes * 1000 * 60)) ~/ 1000;
            final minutesFormatted = minutes.toString().padLeft(2, '0');
            final secondsFormatted = seconds.toString().padLeft(2, '0');
            return Row(
              children: [
                Text(
                  '$minutesFormatted:$secondsFormatted',
                  style: chatTheme.timerTextStyle,
                ),
                SizedBox(width: SdkConstants.rowItemSpace),
                Expanded(
                  child: CustomPaint(
                    painter: WaveformPainter(amplitudes, chatTheme.waveColor),
                    child: SizedBox(width: double.infinity, height: SdkConstants.preferredWaveRecorderHeight),
                  ),
                ),
                IconButton(
                  icon: chatTheme.cancelRecordingIcon,
                  onPressed: () => _handleOnCancel(chatBloc),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
