// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_input/chat_input.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/single_child_widget.dart';

class MockMessagesBloc extends MockBloc<MessagesEvent, MessagesState>
    implements MessagesBloc {
  @override
  Clock get blocClock => Clock.fixed(DateTime(2025));
}

class MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

class MockImageBloc extends MockBloc<ImageEvent, ImageState>
    implements ImageBloc {}

void main() {
  group(ChatInput, () {
    late ChatThemeCubit chatThemeCubit;
    late MessagesBloc messagesBloc;
    late AudioBloc audioBloc;
    late ImageBloc imageBloc;
    late List<SingleChildWidget> blocs;
    late StreamController<AudioState> audioStreamController;

    setUp(() {
      chatThemeCubit = ChatThemeCubit(chatTheme: ChatTheme());
      messagesBloc = MockMessagesBloc();
      audioBloc = MockAudioBloc();
      imageBloc = MockImageBloc();
      audioStreamController = StreamController();
      blocs = [
        BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
        BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
        BlocProvider<AudioBloc>(create: (context) => audioBloc),
        BlocProvider<ImageBloc>(create: (context) => imageBloc),
      ];
    });

    tearDown(() {
      audioStreamController.close();
    });

    group('send message', () {
      testWidgets(
        'should send message correctly when clicking the action button while userMessage is not empty',
        (tester) async {
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: 'Teeest message'));

          when(() => audioBloc.state).thenReturn(AudioState());
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(hintText: 'test', showCameraButton: true, blocs: blocs),
          );
          final actionButtonFinder = find.byIcon(
            chatThemeCubit.state.sendButtonIcon.icon!,
          );

          expect(actionButtonFinder, findsOneWidget);
          await tester.tap(actionButtonFinder);
          await tester.pump();
          verify(
            () => messagesBloc.add(
              ChatSendMessage(
                message: ChatMessage(
                  role: MessageRole.user,
                  type: MessageType.text,
                  content: 'Teeest message',
                  timestamp: messagesBloc.blocClock.now(),
                ),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'should change from record audio icon to send message icon when a message is written',
        (tester) async {
          whenListen(
            messagesBloc,
            Stream<MessagesState>.fromIterable([
              MessagesState(),
              MessagesState(userMessage: 'test'),
              MessagesState(userMessage: 'test 1'),
            ]),
          );
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: ''));
          when(() => audioBloc.state).thenReturn(AudioState());
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(hintText: 'test', showCameraButton: true, blocs: blocs),
          );
          final actionButtonFinder = find.byIcon(
            chatThemeCubit.state.recordAudioIcon.icon!,
          );
          final textFieldFinder = find.byKey(const Key('MessageTextField'));

          expect(actionButtonFinder, findsOneWidget);
          await tester.enterText(textFieldFinder, 'test');
          await tester.pumpAndSettle();
          await tester.enterText(textFieldFinder, 'test 1');
          await tester.pumpAndSettle();
          final actionButtonSendFinder = find.byIcon(
            chatThemeCubit.state.sendButtonIcon.icon!,
          );
          expect(actionButtonSendFinder, findsOneWidget);
          verify(
            () => messagesBloc.add(ChatUpdateUserMessage(value: 'test 1')),
          ).called(1);
        },
      );
    });

    group('record audio', () {
      testWidgets(
        'should emit a start recording event when the user clicks the microphone icon',
        (tester) async {
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: ''));
          when(() => audioBloc.state).thenReturn(AudioState());
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(hintText: 'test', showCameraButton: true, blocs: blocs),
          );
          final actionButtonFinder = find.byIcon(
            chatThemeCubit.state.recordAudioIcon.icon!,
          );
          expect(actionButtonFinder, findsOneWidget);
          await tester.tap(actionButtonFinder);
          await tester.pumpAndSettle();
          verify(() => audioBloc.add(AudioStartRecording())).called(1);
        },
      );

      testWidgets(
        'should show the waveform recorder when the user is recording audio, clicking the send icon emits stop recording and send message',
        (tester) async {
          final List<double> mockAmplitudes = [-30, 0, 0, -30];
          final List<double> mockPreview = [-30, 0, 0, -30];
          final mockDuration = 3;
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: ''));
          when(() => audioBloc.state).thenReturn(
            AudioState(
              isUserRecordingAudio: true,
              amplitudes: mockAmplitudes,
              amplitudesFilePreview: mockPreview,
              millisecondsRecording: mockDuration,
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(hintText: 'test', showCameraButton: true, blocs: blocs),
          );
          final waveformFinder = find.byKey(const Key('WaveformRecorder'));
          expect(waveformFinder, findsOneWidget);

          final actionButtonFinder = find.byIcon(
            chatThemeCubit.state.sendButtonIcon.icon!,
          );
          expect(actionButtonFinder, findsOneWidget);
          await tester.tap(actionButtonFinder);
          await tester.pumpAndSettle();
          verify(() => audioBloc.add(AudioStopRecording())).called(1);
          verify(
            () => messagesBloc.add(
              ChatSendMessage(
                message: ChatMessage.voice(
                  id: null,
                  fileName: '',
                  role: MessageRole.user,
                  amplitudes: mockPreview,
                  duration: mockDuration,
                  timestamp: messagesBloc.blocClock.now(),
                ),
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'should animate the waveform when new data points are added and be able to cancel the recording successfully',
        (tester) async {
          final mockDuration = 3;
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: ''));

          final events = [
            AudioState(
              isUserRecordingAudio: true,
              amplitudes: [-30, 0, -30, -20],
              amplitudesFilePreview: [-30, 0, -30, -20],
              millisecondsRecording: mockDuration + 1,
            ),
            AudioState(
              isUserRecordingAudio: true,
              amplitudes: [-30, -30, -20, -10],
              amplitudesFilePreview: [-30, -30, -20, -10],
              millisecondsRecording: mockDuration + 2,
            ),
          ];
          final stateStream = audioStreamController.stream;
          whenListen(
            audioBloc,
            stateStream,
            initialState: AudioState(
              isUserRecordingAudio: true,
              amplitudes: [-30, 0, 0, -30],
              amplitudesFilePreview: [-30, 0, 0, -30],
              millisecondsRecording: mockDuration,
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(hintText: 'test', showCameraButton: true, blocs: blocs),
          );
          audioStreamController.sink.add(events[0]);
          await tester.pumpAndSettle(Duration(milliseconds: 1));
          audioStreamController.sink.add(events[1]);
          await tester.pumpAndSettle(Duration(milliseconds: 1));
          final waveformFinder = find.byKey(const Key('WaveformRecorder'));
          expect(waveformFinder, findsOneWidget);

          final cancelButtonFinder = find.byIcon(
            chatThemeCubit.state.cancelRecordingIcon.icon!,
          );
          expect(cancelButtonFinder, findsOneWidget);
          await tester.tap(cancelButtonFinder);
          await tester.pumpAndSettle();

          verify(() => audioBloc.add(AudioStopRecording())).called(1);
        },
      );
    });

    group('attach image', () {
      testWidgets('should attach an image', (tester) async {
        when(() => messagesBloc.state).thenReturn(MessagesState());
        when(() => audioBloc.state).thenReturn(AudioState());
        when(() => imageBloc.state).thenReturn(ImageState());

        await tester.pumpWidget(
          TestWidget(hintText: 'test', showCameraButton: true, blocs: blocs),
        );
        final cameraButtonFinder = find.byKey(const Key('CameraButton'));

        expect(cameraButtonFinder, findsOneWidget);
        await tester.tap(cameraButtonFinder);
        await tester.pump();
        // TODO: verify camera handler
      });
      testWidgets(
        'should not find the camera button when showCameraButton is false',
        (tester) async {
          when(() => messagesBloc.state).thenReturn(MessagesState());
          when(() => audioBloc.state).thenReturn(AudioState());
          when(() => imageBloc.state).thenReturn(ImageState());
          await tester.pumpWidget(
            TestWidget(hintText: 'test', showCameraButton: false, blocs: blocs),
          );
          final cameraButtonFinder = find.byKey(const Key('CameraButton'));

          expect(cameraButtonFinder, isNot(findsOneWidget));
        },
      );
    });
  });
}

class TestWidget extends StatelessWidget {
  final String hintText;
  final bool showCameraButton;
  final List<SingleChildWidget> blocs;
  const TestWidget({
    super.key,
    required this.hintText,
    required this.showCameraButton,
    required this.blocs,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Widget',
      home: MultiBlocProvider(
        providers: blocs,
        child: Scaffold(
          appBar: AppBar(title: Text('Test')),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(child: Container()),
                ChatInput(
                  hintText: hintText,
                  showCameraButton: showCameraButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
