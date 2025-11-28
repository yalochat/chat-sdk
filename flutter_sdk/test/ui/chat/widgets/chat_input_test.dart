// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/domain/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_state.dart';
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

class MockMessagesBloc extends MockBloc<MessagesEvent, MessagesState>
    implements MessagesBloc {
  @override
  Clock get blocClock => Clock.fixed(clock.now());
}

class MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

void main() {
  group(ChatInput, () {
    late ChatThemeCubit chatThemeCubit;
    late MessagesBloc messagesBloc;
    late AudioBloc audioBloc;

    setUp(() {
      chatThemeCubit = ChatThemeCubit(chatTheme: ChatTheme());
      messagesBloc = MockMessagesBloc();
      audioBloc = MockAudioBloc();
    });

    group('send message', () {
      testWidgets(
        'should send message correctly when clicking the action button while userMessage is not empty',
        (tester) async {
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: 'Teeest message'));

          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ChatThemeCubit>(
                  create: (context) => chatThemeCubit,
                ),
                BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
                BlocProvider<AudioBloc>(create: (context) => audioBloc),
              ],
              child: const TestWidget(hintText: 'test', showCameraButton: true),
            ),
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

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ChatThemeCubit>(
                  create: (context) => chatThemeCubit,
                ),
                BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
                BlocProvider<AudioBloc>(create: (context) => audioBloc),
              ],
              child: const TestWidget(hintText: 'test', showCameraButton: true),
            ),
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
      testWidgets('should offer to record audio when the message is empty', (
        tester,
      ) async {
        when(
          () => messagesBloc.state,
        ).thenReturn(MessagesState(userMessage: ''));
        when(() => audioBloc.state).thenReturn(AudioState());

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
              BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
              BlocProvider<AudioBloc>(create: (context) => audioBloc),
            ],
            child: const TestWidget(hintText: 'test', showCameraButton: true),
          ),
        );
        final actionButtonFinder = find.byIcon(
          chatThemeCubit.state.recordAudioIcon.icon!,
        );

        expect(actionButtonFinder, findsOneWidget);
        // TODO: Test record audio here
        // await tester.tap(actionButtonFinder);
        // await tester.pump();
      });
    });

    group('attach image', () {
      testWidgets('should attach an image', (tester) async {
        when(() => messagesBloc.state).thenReturn(MessagesState());
        when(() => audioBloc.state).thenReturn(AudioState());

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
              BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
              BlocProvider<AudioBloc>(create: (context) => audioBloc),
            ],
            child: const TestWidget(hintText: 'test', showCameraButton: true),
          ),
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
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ChatThemeCubit>(
                  create: (context) => chatThemeCubit,
                ),
                BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
                BlocProvider<AudioBloc>(create: (context) => audioBloc),
              ],
              child: const TestWidget(
                hintText: 'test',
                showCameraButton: false,
              ),
            ),
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
  const TestWidget({
    super.key,
    required this.hintText,
    required this.showCameraButton,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Widget',
      home: Scaffold(
        appBar: AppBar(title: Text('Test')),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(child: Container()),
              ChatInput(hintText: hintText, showCameraButton: showCameraButton),
            ],
          ),
        ),
      ),
    );
  }
}
