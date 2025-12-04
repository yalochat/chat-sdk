// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:equatable/equatable.dart';

sealed class AudioEvent {}

final class AudioAmplitudeSubscribe extends AudioEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that starts recording audio
final class AudioStartRecording extends AudioEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that stops recording audio
final class AudioStopRecording extends AudioEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event that starts playing an audio
final class AudioPlay extends AudioEvent with EquatableMixin {
  final ChatMessage message;
  AudioPlay({required this.message});
  @override
  List<Object?> get props => [message];
}

// Event that stops playing audio
final class AudioStop extends AudioEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}

// Event to subscribe to a stream that emits events if an audio has been stopped playing
final class AudioCompletedSubscribe extends AudioEvent with EquatableMixin {
  @override
  List<Object?> get props => [];
}
