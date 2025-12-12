// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/domain/models/audio/audio_data.dart';
import 'package:chat_flutter_sdk/src/domain/models/image/image_data.dart';
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
    late StreamController<ImageState> imageStreamController;

    setUp(() {
      chatThemeCubit = ChatThemeCubit(chatTheme: ChatTheme());
      messagesBloc = MockMessagesBloc();
      audioBloc = MockAudioBloc();
      imageBloc = MockImageBloc();
      audioStreamController = StreamController();
      imageStreamController = StreamController();
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
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
          );
          final actionButtonFinder = find.byIcon(
            chatThemeCubit.state.sendButtonIcon.icon!,
          );

          expect(actionButtonFinder, findsOneWidget);
          await tester.tap(actionButtonFinder);
          await tester.pump();
          verify(() => messagesBloc.add(ChatSendTextMessage())).called(1);
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
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
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
      testWidgets(
        'should emit a start recording event when the user clicks the microphone icon',
        (tester) async {
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: ''));
          when(() => audioBloc.state).thenReturn(AudioState());
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
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
              audioData: AudioData(
                amplitudes: mockAmplitudes,
                amplitudesFilePreview: mockPreview,
                duration: mockDuration,
                fileName: 'test.wav',
              ),
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
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
              ChatSendVoiceMessage(
                audioData: AudioData(
                  amplitudes: mockAmplitudes,
                  amplitudesFilePreview: mockPreview,
                  fileName: 'test.wav',
                  duration: 3,
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
              audioData: AudioData(
                amplitudes: [-30, 0, -30, -20],
                amplitudesFilePreview: [-30, 0, -30, -20],
                duration: mockDuration + 1,
              ),
            ),
            AudioState(
              isUserRecordingAudio: true,
              audioData: AudioData(
                amplitudes: [-30, -30, -20, -10],
                amplitudesFilePreview: [-30, -30, -20, -10],
                duration: mockDuration + 2,
              ),
            ),
          ];
          final stateStream = audioStreamController.stream;
          whenListen(
            audioBloc,
            stateStream,
            initialState: AudioState(
              isUserRecordingAudio: true,
              audioData: AudioData(
                amplitudes: [-30, 0, 0, -30],
                amplitudesFilePreview: [-30, 0, 0, -30],
                duration: mockDuration,
              ),
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());

          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
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
      testWidgets(
        'should attach an image from camera and display a preview of it, then remove it because the user cancelled it',
        (tester) async {
          when(() => messagesBloc.state).thenReturn(MessagesState());
          when(() => audioBloc.state).thenReturn(AudioState());

          final initialState = ImageState();
          final stateStream = imageStreamController.stream;
          whenListen(imageBloc, stateStream, initialState: initialState);

          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
          );
          final attachmentButtonFinder = find.byKey(
            const Key('AttachmentButton'),
          );

          expect(attachmentButtonFinder, findsOneWidget);
          await tester.tap(attachmentButtonFinder);
          await tester.pumpAndSettle(Duration(seconds: 1));

          final cameraPickerButton = find.byKey(Key('CameraPickerButton'));
          final galleryPickerButton = find.byKey(Key('GalleryPickerButton'));
          expect(cameraPickerButton, findsOneWidget);
          expect(galleryPickerButton, findsOneWidget);

          await tester.tap(cameraPickerButton);
          verify(() => imageBloc.add(ImagePickFromCamera())).called(1);

          imageStreamController.sink.add(
            initialState.copyWith(
              pickedImage: () => ImageData(
                path: 'images/test-image.png',
                mimeType: 'image/png',
              ),
            ),
          );

          await tester.pumpAndSettle(Duration(seconds: 1));
          final previewFinder = find.byKey(Key('ImagePreview'));
          expect(previewFinder, findsOneWidget);

          final trashButtonFinder = find.byIcon(
            chatThemeCubit.chatTheme.trashIcon.icon!,
          );

          expect(trashButtonFinder, findsOneWidget);
          await tester.tap(trashButtonFinder);
          verify(() => imageBloc.add(ImageCancelPick())).called(1);
          imageStreamController.sink.add(
            initialState.copyWith(pickedImage: () => null),
          );
          await tester.pumpAndSettle(Duration(seconds: 1));
          expect(find.byKey(Key('ImagePreview')), isNot(findsOneWidget));
        },
      );

      testWidgets(
        'should attach an image from gallery and display a preview of it, then send it correctly, all in portrait mode',
        (tester) async {
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: 'test'));
          when(() => audioBloc.state).thenReturn(AudioState());

          tester.view.physicalSize = const Size(600, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
          });

          final initialState = ImageState();
          final stateStream = imageStreamController.stream;
          whenListen(imageBloc, stateStream, initialState: initialState);

          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
          );
          final attachmentButtonFinder = find.byKey(
            const Key('AttachmentButton'),
          );

          expect(attachmentButtonFinder, findsOneWidget);
          await tester.tap(attachmentButtonFinder);
          await tester.pumpAndSettle(Duration(seconds: 1));

          final cameraPickerButton = find.byKey(Key('CameraPickerButton'));
          final galleryPickerButton = find.byKey(Key('GalleryPickerButton'));
          expect(cameraPickerButton, findsOneWidget);
          expect(galleryPickerButton, findsOneWidget);

          await tester.tap(galleryPickerButton);
          verify(() => imageBloc.add(ImagePickFromGallery())).called(1);

          imageStreamController.sink.add(
            initialState.copyWith(
              pickedImage: () => ImageData(
                path: 'images/test-image.png',
                mimeType: 'image/png',
              ),
            ),
          );

          await tester.pumpAndSettle(Duration(seconds: 1));
          final previewFinder = find.byKey(Key('ImagePreview'));
          expect(previewFinder, findsOneWidget);

          final sendButton = find.byIcon(
            chatThemeCubit.chatTheme.sendButtonIcon.icon!,
          );

          expect(sendButton, findsOneWidget);
          await tester.tap(sendButton);
          verify(() => imageBloc.add(ImageHidePreview())).called(1);
          verify(
            () => messagesBloc.add(
              ChatSendImageMessage(
                imageData: ImageData(
                  path: 'images/test-image.png',
                  mimeType: 'image/png',
                ),
                text: 'test',
              ),
            ),
          ).called(1);
          imageStreamController.sink.add(
            initialState.copyWith(pickedImage: () => null),
          );
          await tester.pumpAndSettle(Duration(seconds: 1));
          expect(find.byKey(Key('ImagePreview')), isNot(findsOneWidget));
        },
      );

      testWidgets(
        'should hide the image preview when the picker is opened again, close the picker when the exit button is pressed, the image preview should be shown after close',
        (tester) async {
          when(
            () => messagesBloc.state,
          ).thenReturn(MessagesState(userMessage: 'test'));
          when(() => audioBloc.state).thenReturn(AudioState());

          final initialState = ImageState();
          final stateStream = imageStreamController.stream;
          whenListen(imageBloc, stateStream, initialState: initialState);
          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: true,
              blocs: blocs,
            ),
          );

          final imageDataStub = ImageData(
            path: 'images/test-image.png',
            mimeType: 'image/png',
          );
          imageStreamController.sink.add(
            ImageState(pickedImage: imageDataStub),
          );
          await tester.pumpAndSettle(Duration(seconds: 1));

          final initPreviewFinder = find.byKey(Key('ImagePreview'));
          expect(initPreviewFinder, findsOneWidget);

          final attachmentButtonFinder = find.byKey(
            const Key('AttachmentButton'),
          );

          expect(attachmentButtonFinder, findsOneWidget);
          await tester.tap(attachmentButtonFinder);
          verify(() => imageBloc.add(ImageHidePreview())).called(1);
          imageStreamController.sink.add(ImageState());
          await tester.pumpAndSettle(Duration(seconds: 1));

          final imagePreviewFinder = find.byKey(Key('ImagePreview'));
          expect(imagePreviewFinder, isNot(findsOneWidget));

          final cameraPickerButton = find.byKey(Key('CameraPickerButton'));
          final galleryPickerButton = find.byKey(Key('GalleryPickerButton'));
          final exitButton = find.byIcon(
            chatThemeCubit.chatTheme.closeModalIcon.icon!,
          );
          expect(cameraPickerButton, findsOneWidget);
          expect(galleryPickerButton, findsOneWidget);
          expect(exitButton, findsOneWidget);

          await tester.tap(exitButton);
          imageStreamController.sink.add(
            ImageState(pickedImage: imageDataStub),
          );
          await tester.pumpAndSettle(Duration(seconds: 1));
          verify(() => imageBloc.add(ImageShowPreview())).called(1);
          final previewFinder = find.byKey(Key('ImagePreview'));
          expect(previewFinder, findsOneWidget);
        },
      );

      testWidgets(
        'should not find the attachment button when showAttachmentButton is false',
        (tester) async {
          when(() => messagesBloc.state).thenReturn(MessagesState());
          when(() => audioBloc.state).thenReturn(AudioState());
          when(() => imageBloc.state).thenReturn(ImageState());
          await tester.pumpWidget(
            TestWidget(
              hintText: 'test',
              showAttachmentButton: false,
              blocs: blocs,
            ),
          );
          final attachmentButtonFinder = find.byKey(
            const Key('AttachmentButton'),
          );

          expect(attachmentButtonFinder, isNot(findsOneWidget));
        },
      );
    });
  });
}

class TestWidget extends StatelessWidget {
  final String hintText;
  final bool showAttachmentButton;
  final List<SingleChildWidget> blocs;
  const TestWidget({
    super.key,
    required this.hintText,
    required this.showAttachmentButton,
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
                  showAttachmentButton: showAttachmentButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
