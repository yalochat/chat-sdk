// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart'
    show ChatMessage;
import 'package:equatable/equatable.dart';

final class AudioState extends Equatable {

  // Amplitudes that are shown to the user during a recording
  // session as a scrolling drawing
  final List<double> amplitudes;

  // The preview of the whole recording that will be stored in the DB
  // and be rendered in the message list
  final List<double> amplitudesFilePreview;
  final int millisecondsRecording;
  final int amplitudeIndex;
  final String audioFileName;
  final bool isUserRecordingAudio;
  final ChatMessage? playingMessage;

  AudioState({
    List<double>? amplitudes,
    List<double>? amplitudesFilePreview,
    this.millisecondsRecording = 0,
    this.amplitudeIndex = 0,
    this.audioFileName = '',
    this.isUserRecordingAudio = false,
    this.playingMessage,
  }) : amplitudes = amplitudes ?? <double>[],
       amplitudesFilePreview = amplitudesFilePreview ?? <double>[];

  AudioState copyWith({
    List<double>? amplitudes,
    List<double>? amplitudesFilePreview,
    int? millisecondsRecording,
    int? amplitudeIndex,
    String? audioFileName,
    bool? isUserRecordingAudio,
    ChatMessage? Function()? playingMessage,
  }) {
    return AudioState(
      amplitudes: amplitudes ?? this.amplitudes,
      amplitudesFilePreview:
          amplitudesFilePreview ?? this.amplitudesFilePreview,
      millisecondsRecording:
          millisecondsRecording ?? this.millisecondsRecording,
      amplitudeIndex: amplitudeIndex ?? this.amplitudeIndex,
      audioFileName: audioFileName ?? this.audioFileName,
      isUserRecordingAudio: isUserRecordingAudio ?? this.isUserRecordingAudio,
      playingMessage: playingMessage != null
          ? playingMessage()
          : this.playingMessage,
    );
  }

  @override
  List<Object?> get props => [
    amplitudes,
    amplitudesFilePreview,
    millisecondsRecording,
    amplitudeIndex,
    audioFileName,
    isUserRecordingAudio,
    playingMessage,
  ];
}
