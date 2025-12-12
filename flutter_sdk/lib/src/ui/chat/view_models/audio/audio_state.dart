// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart'
    show ChatMessage;
import 'package:equatable/equatable.dart';

enum AudioStatus {
  errorStoppingAudio,
  errorPlayingAudio,
  errorStoppingRecording,
  errorRecordingAudio,
  recordingAudio,
  playingAudio,
  audioPaused,
  initial,
}

final class AudioState extends Equatable {
  final AudioData audioData;
  final int amplitudeIndex;
  final bool isUserRecordingAudio;
  final AudioStatus audioStatus;

  final ChatMessage? playingMessage;

  AudioState({
    AudioData? audioData,
    this.amplitudeIndex = 0,
    this.isUserRecordingAudio = false,
    this.playingMessage,
    this.audioStatus = AudioStatus.initial,
  }): audioData = audioData ?? AudioData();

  AudioState copyWith({
    AudioData? audioData,
    int? amplitudeIndex,
    bool? isUserRecordingAudio,
    ChatMessage? Function()? playingMessage,
    AudioStatus? audioStatus,
  }) {
    return AudioState(
      audioData: audioData ?? this.audioData,
      amplitudeIndex: amplitudeIndex ?? this.amplitudeIndex,
      isUserRecordingAudio: isUserRecordingAudio ?? this.isUserRecordingAudio,
      playingMessage: playingMessage != null
          ? playingMessage()
          : this.playingMessage,
      audioStatus: audioStatus ?? this.audioStatus,
    );
  }

  @override
  List<Object?> get props => [
    audioData,
    amplitudeIndex,
    isUserRecordingAudio,
    playingMessage,
    audioStatus,
  ];
}
