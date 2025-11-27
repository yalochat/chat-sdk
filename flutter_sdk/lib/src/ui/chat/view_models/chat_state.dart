// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:equatable/equatable.dart';

enum ChatStatus {
  initial,
  success,
  failure,
  offline,
  failedMessageSent,
  failedRecordMessage,
}

class ChatState extends Equatable {
  final List<ChatMessage> messages;

  // Amplitudes that are shown to the during a recording session
  final List<double> amplitudes;
  // Its the preview of the whole recording that will be stored in the DB
  final List<double> amplitudesFilePreview;
  final int millisecondsRecording;
  final int amplitudeIndex;
  final String audioFileName;
  final String userMessage;
  final bool isConnected;
  final bool isLoading;
  final bool isSystemTypingMessage;
  final bool isUserRecordingAudio;
  final ChatMessage? playingMessage;
  final String chatTitle;
  final ChatStatus chatStatus;
  final String chatStatusText;
  final PageInfo pageInfo;

  ChatState({
    List<ChatMessage>? messages,
    List<double>? amplitudes,
    List<double>? amplitudesFilePreview,
    this.millisecondsRecording = 0,
    this.amplitudeIndex = 0,
    this.audioFileName = '',
    this.userMessage = '',
    this.isConnected = false,
    this.isLoading = false,
    this.isSystemTypingMessage = false,
    this.isUserRecordingAudio = false,
    this.playingMessage,
    this.chatTitle = '',
    this.chatStatus = ChatStatus.initial,
    this.chatStatusText = '',
    this.pageInfo = const PageInfo(
      cursor: null,
      pageSize: 30,
      nextCursor: null,
    ),
  }) : messages = messages ?? <ChatMessage>[],
       amplitudes = amplitudes ?? <double>[],
       amplitudesFilePreview = amplitudesFilePreview ?? <double>[];

  ChatState copyWith({
    List<ChatMessage>? messages,
    List<double>? amplitudes,
    List<double>? amplitudesFilePreview,
    int? millisecondsRecording,
    int? amplitudeIndex,
    String? audioFileName,
    String? userMessage,
    bool? isConnected,
    bool? isLoading,
    bool? isSystemTypingMessage,
    bool? isUserRecordingAudio,
    ChatMessage? playingMessage,
    String? chatTitle,
    ChatStatus? chatStatus,
    String? chatStatusText,
    PageInfo? pageInfo,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      amplitudes: amplitudes ?? this.amplitudes,
      amplitudesFilePreview:
          amplitudesFilePreview ?? this.amplitudesFilePreview,
      millisecondsRecording:
          millisecondsRecording ?? this.millisecondsRecording,
      amplitudeIndex: amplitudeIndex ?? this.amplitudeIndex,
      audioFileName: audioFileName ?? this.audioFileName,
      userMessage: userMessage ?? this.userMessage,
      isConnected: isConnected ?? this.isConnected,
      isLoading: isLoading ?? this.isLoading,
      isSystemTypingMessage:
          isSystemTypingMessage ?? this.isSystemTypingMessage,
      isUserRecordingAudio: isUserRecordingAudio ?? this.isUserRecordingAudio,
      playingMessage: playingMessage ?? this.playingMessage,
      chatTitle: chatTitle ?? this.chatTitle,
      chatStatus: chatStatus ?? this.chatStatus,
      chatStatusText: chatStatusText ?? this.chatStatusText,
      pageInfo: pageInfo ?? this.pageInfo,
    );
  }

  @override
  List<Object?> get props => [
    messages,
    amplitudes,
    amplitudesFilePreview,
    millisecondsRecording,
    amplitudeIndex,
    audioFileName,
    userMessage,
    isConnected,
    isLoading,
    isSystemTypingMessage,
    isUserRecordingAudio,
    playingMessage,
    chatTitle,
    chatStatus,
    chatStatusText,
    pageInfo,
  ];
}
