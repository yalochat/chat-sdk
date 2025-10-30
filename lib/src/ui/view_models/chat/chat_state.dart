// Copyright (c) Yalochat, Inc. All rights reserved.

class ChatState {
  final List<String> messages;
  final String userMessage;
  final bool isConnected;
  final bool isTypingMessage;
  final bool isRecordingAudio;

  ChatState({
    this.messages = const <String>[],
    this.userMessage = "",
    required this.isConnected,
    required this.isTypingMessage,
    required this.isRecordingAudio,
  });

  ChatState copyWith({
    List<String>? messages,
    String? userMessage,
    bool? isConnected,
    bool? isTypingMessage,
    bool? isRecordingAudio,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      userMessage: userMessage ?? this.userMessage,
      isConnected: isConnected ?? this.isConnected,
      isTypingMessage: isTypingMessage ?? this.isTypingMessage,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
    );
  }
}
