// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:math';

import 'package:chat_flutter_sdk/src/common/page.dart';
import 'package:chat_flutter_sdk/src/common/result.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/ui/theme/constants.dart';
import 'package:clock/clock.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import 'chat_event.dart';
import 'chat_state.dart';

/// A Bloc for managing the chat state of the Chat Widget of the SDK.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  static const int _recordTickMs = 45;
  static const int _amplitudeDataPoints = 48;
  static const double _defaultAmplitude = -30;
  final Clock _clock;
  final ChatMessageRepository _chatMessageRepository;
  final AudioRepository _audioRepository;
  final Logger log = Logger('ChatViewModel');

  ChatBloc({
    String name = '',
    required ChatMessageRepository chatMessageRepository,
    required AudioRepository audioRepository,
    int pageSize = SdkConstants.defaultPageSize,
    Clock? clock,
  }) : _clock = clock ?? Clock(),
       _chatMessageRepository = chatMessageRepository,
       _audioRepository = audioRepository,
       super(
         ChatState(
           isConnected: false,
           isUserRecordingAudio: false,
           isSystemTypingMessage: false,
           chatTitle: name,
           pageInfo: PageInfo(pageSize: pageSize),
           amplitudes: List<double>.filled(
             _amplitudeDataPoints,
             _defaultAmplitude,
           ),
           amplitudesFilePreview: List<double>.filled(
             _amplitudeDataPoints,
             _defaultAmplitude,
           ),
           amplitudeIndex: _amplitudeDataPoints - 1,
         ),
       ) {
    on<ChatPlayAudio>(_handlePlayAudio);
    on<ChatStopAudio>(_handleStopAudio);
    on<ChatAmplitudeSubscribe>(_onAmplitudeSubscribe);
    on<ChatLoadMessages>(_handleFetchMessages);
    on<ChatStartRecording>(_handleStartRecording);
    on<ChatStopRecording>(_handleStopRecording);
    on<ChatStartTyping>(_handleStartTyping);
    on<ChatStopTyping>(_handleStopTyping);
    on<ChatUpdateUserMessage>(_handleUpdateUserMessage);
    on<ChatSendMessage>(_handleSendMessage);
    on<ChatClearMessages>(_handleClearMessages);
  }

  // Event that handles the pagination of messages
  Future<void> _handleFetchMessages(
    ChatLoadMessages event,
    Emitter<ChatState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    int? cursor;
    switch (event.direction) {
      case PageDirection.next:
        cursor = state.pageInfo.nextCursor;
        // No more pages
        if (cursor == null) {
          emit(state.copyWith(isLoading: false));
          return;
        }
      case PageDirection.initial:
      // Keep the cursor null
    }

    Result<Page<ChatMessage>> newMessages = await _chatMessageRepository
        .getChatMessagePageDesc(cursor, state.pageInfo.pageSize);
    switch (newMessages) {
      case Ok<Page<ChatMessage>>():
        emit(
          state.copyWith(
            chatStatus: ChatStatus.success,
            // FIXME: Create a new way to track big message list copies
            messages: [...state.messages, ...newMessages.result.data],
            isLoading: false,
            pageInfo: newMessages.result.pageInfo.copyWith(
              prevCursor: state.pageInfo.cursor,
            ),
          ),
        );
        break;
      case Error<Page<ChatMessage>>():
        emit(state.copyWith(chatStatus: ChatStatus.failure, isLoading: false));
        break;
    }
  }

  // Handles the event when the assistant starts typing.
  void _handleStartTyping(ChatStartTyping event, Emitter<ChatState> emit) {
    if (!state.isSystemTypingMessage) {
      emit(
        state.copyWith(
          isSystemTypingMessage: true,
          chatStatusText: event.chatStatusText,
        ),
      );
    }
  }

  // Handles the event when the assistant stops typing.
  void _handleStopTyping(ChatStopTyping event, Emitter<ChatState> emit) {
    if (state.isSystemTypingMessage) {
      emit(state.copyWith(isSystemTypingMessage: false, chatStatusText: ''));
    }
  }

  // Handles the event to update the user message
  void _handleUpdateUserMessage(
    ChatUpdateUserMessage event,
    Emitter<ChatState> emit,
  ) {
    if (event.value != state.userMessage) {
      emit(state.copyWith(userMessage: event.value));
    }
  }

  // Method that compresses the amplitudes to fixed size array keeping only maximumsg
  List<double> _calculateAmplitudeFilePreview(
    double newPoint,
    int totalSamples,
    List<double> amplitudePreview,
  ) {
    final result = [...amplitudePreview];
    final totalBins = amplitudePreview.length;
    if (totalSamples <= totalBins) {
      result[totalSamples - 1] = newPoint;
    } else {
      var targetBin = totalSamples % totalBins;
      for (var i = targetBin; i < result.length - 1; i++) {
        if (i == targetBin) {
          result[i] = max(result[i], result[i + 1]);
        } else {
          result[i] = result[i + 1];
        }
      }
      result.last = newPoint;
    }

    return result;
  }

  Future<void> _onAmplitudeSubscribe(
    ChatAmplitudeSubscribe event,
    Emitter<ChatState> emit,
  ) async {
    final amplitudesStream = _audioRepository.getAmplitudes(
      Duration(milliseconds: _recordTickMs),
    );
    await emit.forEach(
      amplitudesStream,
      onData: (data) {
        assert(!data.isInfinite, 'no infinity values allowed');
        final maxPoints = state.amplitudes.length;
        final millisecondsRecording =
            state.millisecondsRecording + _recordTickMs;
        assert(
          millisecondsRecording % _recordTickMs == 0,
          'Milliseconds must be a multiple of _recordTickMs',
        );
        return state.copyWith(
          // Create an animation of the waves sliding.
          amplitudes: state.amplitudes.sublist(1)..add(data),
          amplitudeIndex: (state.amplitudeIndex - 1) % maxPoints,
          amplitudesFilePreview: _calculateAmplitudeFilePreview(
            data,
            millisecondsRecording ~/ _recordTickMs,
            state.amplitudesFilePreview,
          ),
          millisecondsRecording: millisecondsRecording,
        );
      },
    );
  }

  Future<void> _handleStartRecording(
    ChatStartRecording event,
    Emitter<ChatState> emit,
  ) async {
    log.info('Trying to record audio');
    final audioStreamResult = await _audioRepository.recordAudio();
    switch (audioStreamResult) {
      case Ok():
        log.info(
          'Audio started successfully with file ${audioStreamResult.result}',
        );
        emit(
          state.copyWith(
            isUserRecordingAudio: true,
            audioFileName: audioStreamResult.result,
            userMessage: '',
            amplitudeIndex: state.amplitudes.length - 1,
            amplitudes: List<double>.filled(
              _amplitudeDataPoints,
              _defaultAmplitude,
            ),
            amplitudesFilePreview: List<double>.filled(
              _amplitudeDataPoints,
              _defaultAmplitude,
            ),
            millisecondsRecording: 0,
          ),
        );
        break;
      case Error():
        emit(
          state.copyWith(
            chatStatus: ChatStatus.failedRecordMessage,
            audioFileName: '',
            isUserRecordingAudio: false,
          ),
        );
        break;
    }
  }

  Future<void> _handleStopRecording(
    ChatStopRecording event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _audioRepository.stopRecording();
    switch (result) {
      case Ok():
        emit(state.copyWith(isUserRecordingAudio: false));
        break;
      case Error():
        break;
    }
  }

  // Handles the event when an audio is played, stops all other audios from playing first (if there's any)
  Future<void> _handlePlayAudio(
    ChatPlayAudio event,
    Emitter<ChatState> emit,
  ) async {
    if (event.message.type != MessageType.voice ||
        event.message.fileName == null || event.message.fileName == '') {
      log.warning(
        'No message was played because a non voice message was passed',
      );
      return;
    }

    log.info('Trying to play audio ${event.message.fileName}');
    if (state.playingMessage != null) {
      log.info('Stopping currently playing message');
      final resultPause = await _audioRepository.pauseAudio();
      switch (resultPause) {
        case Ok():
          log.info('Pause previous audio succeeded');
          emit(state.copyWith(playingMessage: () => null));
          break;
        case Error():
          log.severe('Unable to stop audio from playing', resultPause.error);
          break;
      }
    }
    final result = await _audioRepository.playAudio(event.message.fileName!);
    switch (result) {
      case Ok():
        log.info('Playing audio succeeded');
        emit(state.copyWith(playingMessage: () => event.message));
        break;
      case Error():
        log.severe('Unable to play audio', result.error);
        break;
    }
  }

  // Handles the event when a user stops a voice note play
  Future<void> _handleStopAudio(
    ChatStopAudio event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _audioRepository.pauseAudio();
    switch (result) {
      case Ok():
        log.info('Audio stopped correctly');
        emit(state.copyWith(playingMessage: () => null));
        break;
      case Error():
        log.severe('Unable to stop audio', result.error);
        break;
    }
  }

  // Handles the event when the user sends a message
  Future<void> _handleSendMessage(
    ChatSendMessage event,
    Emitter<ChatState> emit,
  ) async {
    final String trimmedMessage = state.userMessage.trim();
    if (trimmedMessage.isEmpty && !state.isUserRecordingAudio) return;

    late ChatMessage messageToInsert;
    if (state.isUserRecordingAudio) {
      final result = await _audioRepository.stopRecording();
      messageToInsert = ChatMessage(
        role: MessageRole.user,
        type: MessageType.voice,
        timestamp: _clock.now(),
        fileName: state.audioFileName,
        amplitudes: state.amplitudesFilePreview,
      );
      switch (result) {
        case Ok():
          emit(state.copyWith(isUserRecordingAudio: false, audioFileName: ''));
          break;
        case Error():
          break;
      }
    } else {
      messageToInsert = ChatMessage(
        role: MessageRole.user,
        type: MessageType.text,
        content: trimmedMessage,
        timestamp: _clock.now(),
      );
    }

    Result<ChatMessage> result = await _chatMessageRepository.insertChatMessage(
      messageToInsert,
    );

    switch (result) {
      case Ok<ChatMessage>():
        emit(
          state.copyWith(
            // FIXME: Create a new way to track big message list copies
            messages: [result.result, ...state.messages],
            userMessage: '',
          ),
        );
        break;
      case Error<ChatMessage>():
        emit(state.copyWith(chatStatus: ChatStatus.failedMessageSent));
        break;
    }
  }

  // Handles the event to clear messages.
  void _handleClearMessages(ChatClearMessages event, Emitter<ChatState> emit) {
    if (state.messages.isEmpty) return;
    emit(state.copyWith(messages: []));
    // TODO: Add the repository to clear messages
  }
}
