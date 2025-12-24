// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/domain/models/product/product.dart';
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
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/message_list.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:clock/clock.dart';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/single_child_widget.dart';

class MockMessagesBloc extends MockBloc<MessagesEvent, MessagesState>
    implements MessagesBloc {}

class MockAudioBloc extends MockBloc<AudioEvent, AudioState>
    implements AudioBloc {}

class MockImageBloc extends MockBloc<ImageEvent, ImageState>
    implements ImageBloc {}

void main() {
  group(MessageList, () {
    late ChatThemeCubit chatThemeCubit;
    late MessagesBloc chatBloc;
    late AudioBloc audioBloc;
    late ImageBloc imageBloc;
    late List<SingleChildWidget> blocs;
    late StreamController<AudioState> audioStreamController;

    setUp(() {
      chatThemeCubit = ChatThemeCubit(chatTheme: ChatTheme());
      chatBloc = MockMessagesBloc();
      audioBloc = MockAudioBloc();
      imageBloc = MockImageBloc();
      audioStreamController = StreamController();
      blocs = [
        BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
        BlocProvider<MessagesBloc>(create: (context) => chatBloc),
        BlocProvider<AudioBloc>(create: (context) => audioBloc),
        BlocProvider<ImageBloc>(create: (context) => imageBloc),
      ];
    });

    tearDown(() {
      audioStreamController.close();
    });

    group('user text messages', () {
      testWidgets('should render user messages correctly', (tester) async {
        when(() => chatBloc.state).thenReturn(
          MessagesState(
            messages: [
              ChatMessage(
                id: 1,
                role: MessageRole.user,
                type: MessageType.text,
                timestamp: clock.now(),
                content: 'user message test',
              ),
            ],
          ),
        );
        await tester.pumpWidget(TestWidget(blocs: blocs));

        final messageFinder = find.text('user message test');
        expect(messageFinder, findsOneWidget);
      });

      testWidgets(
        'should render a lot of user messages correctly and be scrollable to the top',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                for (int i = 0; i < 100; i++)
                  ChatMessage(
                    id: i + 1,
                    role: MessageRole.user,
                    type: MessageType.text,
                    timestamp: clock.now(),
                    content: 'user message test $i',
                  ),
              ],
            ),
          );
          await tester.pumpWidget(TestWidget(blocs: blocs));

          final listFinder = find.byType(Scrollable);
          final listItemFinder = find.byKey(
            ValueKey<String>('message-item-100'),
          );
          await tester.scrollUntilVisible(
            listItemFinder,
            500,
            scrollable: listFinder.first,
          );
          expect(listItemFinder, findsOneWidget);
        },
      );

      testWidgets('should render a loading animation when isLoading is true', (
        tester,
      ) async {
        when(
          () => chatBloc.state,
        ).thenReturn(MessagesState(isLoading: true, messages: [
            ],
          ));
        await tester.pumpWidget(TestWidget(blocs: blocs));

        final loaderFind = find.byKey(const Key('loading_spinner'));
        expect(loaderFind, findsOneWidget);
      });

      testWidgets(
        'should throw an unimplemented error when a unsupported user message is received',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage(
                  id: 8,
                  role: MessageRole.user,
                  timestamp: clock.now(),
                  content:
                      'This is a very large assistant message designed just for testing the widget of yalo\'s flutter SDK',
                  type: MessageType.unknown,
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));
          expect(tester.takeException(), isA<UnimplementedError>());
        },
      );
    });

    group('user voice messages', () {
      testWidgets('should display user voice messages correctly', (
        tester,
      ) async {
        final Random random = Random();
        when(() => chatBloc.state).thenReturn(
          MessagesState(
            messages: [
              for (int i = 0; i < 100; i++)
                ChatMessage.voice(
                  id: i + 1,
                  role: MessageRole.user,
                  timestamp: clock.now(),
                  fileName: 'file-$i.wav',
                  amplitudes: [
                    for (int i = 0; i < 100; i++)
                      -160.0 + random.nextDouble() * 160.0,
                  ],
                  duration: random.nextInt(500),
                ),
              ChatMessage(
                id: 0,
                role: MessageRole.user,
                type: MessageType.text,
                timestamp: clock.now(),
                content: 'user message test 0',
              ),
            ],
          ),
        );
        when(() => audioBloc.state).thenReturn(AudioState());
        await tester.pumpWidget(TestWidget(blocs: blocs));

        final listFinder = find.byType(Scrollable);
        final listItemFinder = find.byKey(ValueKey<String>('message-item-100'));
        await tester.scrollUntilVisible(
          listItemFinder,
          500,
          scrollable: listFinder.first,
        );
        expect(listItemFinder, findsOneWidget);
      });

      testWidgets(
        'should play the audio correctly, show the pause icon after it and then be able to pause it',
        (tester) async {
          final Random random = Random();
          List<ChatMessage> messages = [
            ChatMessage.voice(
              id: 1,
              role: MessageRole.user,
              timestamp: clock.now(),
              fileName: 'file-1.wav',
              amplitudes: [
                for (int i = 0; i < 100; i++)
                  -160.0 + random.nextDouble() * 160.0,
              ],
              duration: random.nextInt(500),
            ),
            ChatMessage.voice(
              id: 2,
              role: MessageRole.user,
              timestamp: clock.now(),
              fileName: 'file-1.wav',
              amplitudes: [
                for (int i = 0; i < 100; i++)
                  -160.0 + random.nextDouble() * 160,
              ],
              duration: random.nextInt(500),
            ),
          ];
          when(
            () => chatBloc.state,
          ).thenReturn(MessagesState(messages: messages));

          final audioStream = audioStreamController.stream.asBroadcastStream();
          whenListen(audioBloc, audioStream, initialState: AudioState());
          await tester.pumpWidget(TestWidget(blocs: blocs));

          final messageItem = find.byKey(ValueKey<String>('message-item-1'));
          final playMessageFinder = find.descendant(
            of: messageItem,
            matching: find.byIcon(chatThemeCubit.chatTheme.playAudioIcon),
          );
          expect(playMessageFinder, findsOneWidget);
          await tester.tap(playMessageFinder);
          audioStreamController.sink.add(
            AudioState(playingMessage: messages[0]),
          );
          await tester.pumpAndSettle(Duration(milliseconds: 1));
          verify(
            () => audioBloc.add(AudioPlay(message: messages[0])),
          ).called(1);
          final pauseButtonFinder = find.descendant(
            of: messageItem,
            matching: find.byIcon(chatThemeCubit.state.pauseAudioIcon),
          );
          expect(pauseButtonFinder, findsOneWidget);
          await tester.tap(pauseButtonFinder);
          audioStreamController.sink.add(AudioState(playingMessage: null));
          await tester.pumpAndSettle(Duration(milliseconds: 1));
          verify(() => audioBloc.add(AudioStop())).called(1);
        },
      );
    });

    group('user image messages', () {
      testWidgets(
        'should render a image message correctly without content text',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.image(
                  id: 1,
                  role: MessageRole.user,
                  timestamp: clock.now(),
                  content: '',
                  fileName: 'images/test-image.png',
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));
          final imageFinder = find.byType(Image);
          expect(imageFinder, findsOneWidget);
          final textFinder = find.text('');
          expect(textFinder, isNot(findsOneWidget));
        },
      );

      testWidgets('should render a image message correctly with content text', (
        tester,
      ) async {
        when(() => chatBloc.state).thenReturn(
          MessagesState(
            messages: [
              ChatMessage.image(
                id: 1,
                role: MessageRole.user,
                timestamp: clock.now(),
                content: 'test content',
                fileName: 'images/test-image.png',
              ),
            ],
          ),
        );
        when(() => imageBloc.state).thenReturn(ImageState());
        when(() => audioBloc.state).thenReturn(AudioState());

        await tester.pumpWidget(TestWidget(blocs: blocs));
        final imageFinder = find.byType(Image);
        expect(imageFinder, findsOneWidget);
        final textFinder = find.text('test content');
        expect(textFinder, findsOneWidget);
      });
    });

    group('assistant text messages', () {
      testWidgets('should render a assistant text message correctly', (
        tester,
      ) async {
        when(() => chatBloc.state).thenReturn(
          MessagesState(
            messages: [
              ChatMessage.text(
                id: 8,
                role: MessageRole.assistant,
                timestamp: clock.now(),
                content:
                    'This is a very large assistant message designed just for testing the widget of yalo\'s flutter SDK',
              ),
            ],
          ),
        );
        when(() => imageBloc.state).thenReturn(ImageState());
        when(() => audioBloc.state).thenReturn(AudioState());

        await tester.pumpWidget(TestWidget(blocs: blocs));

        final textFinder = find.textContaining(r'large assistant');
        expect(textFinder, findsOneWidget);
      });

      testWidgets(
        'should render product messages correctly and be able to add, edit and remove units',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.product(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  products: [
                    Product(
                      sku: '123',
                      name: 'test product without name',
                      price: 30.0,
                      salePrice: 29.0,
                      subunits: 24,
                      unitName: '{amount, plural, one {box} other {boxes}}',
                      subunitName: '{amount, plural, one {unit} other {units}}',
                    ),
                  ],
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));

          expect(find.text('test product without name'), findsOneWidget);
          expect(find.text('24 units'), findsOneWidget);
          expect(find.text('0 boxes'), findsOneWidget);
          expect(find.text('0 units'), findsOneWidget);

          final addFinder = find.byIcon(Icons.add);
          final removeFinder = find.byIcon(Icons.remove);
          final textFieldFinder = find.byType(TextField);
          expect(addFinder, findsNWidgets(2));
          expect(removeFinder, findsNWidgets(2));
          expect(textFieldFinder, findsNWidgets(2));
          await tester.tap(addFinder.first);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.unit,
                quantity: 1,
              ),
            ),
          ).called(1);

          await tester.tap(removeFinder.first);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.unit,
                quantity: -1.0,
              ),
            ),
          ).called(1);

          await tester.tap(addFinder.last);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.subunit,
                quantity: 1,
              ),
            ),
          ).called(1);

          await tester.tap(removeFinder.last);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.subunit,
                quantity: -1.0,
              ),
            ),
          ).called(1);

          // Verify text edition
          await tester.pumpAndSettle();
          await tester.enterText(textFieldFinder.first, '3');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.unit,
                quantity: 3.0,
              ),
            ),
          ).called(1);

          await tester.enterText(textFieldFinder.last, '3');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.subunit,
                quantity: 3.0,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'should render list product messages correctly, with more than 3 elements and be able to expand the message',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.product(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  products: [
                    for (int i = 0; i < 4; i++)
                      Product(
                        sku: '123$i',
                        name: 'test product without name $i',
                        price: 30.0 + i.toDouble(),
                        salePrice: 29.0 + i.toDouble(),
                        subunits: 24,
                        unitName: '{amount, plural, one {box} other {boxes}}',
                        subunitName:
                            '{amount, plural, one {unit} other {units}}',
                      ),
                  ],
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));
          final showMoreButton = find.text('Show more');
          expect(showMoreButton, findsOneWidget);
          await tester.tap(showMoreButton);
          verify(() => chatBloc.add(ChatToggleMessageExpand(messageId: 8)));
        },
      );

      testWidgets(
        'should render carousel  messages correctly, with more than 3 elements and be able to expand the message',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.carousel(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  products: [
                    for (int i = 0; i < 4; i++)
                      Product(
                        sku: '123$i',
                        name: 'test product without name $i',
                        price: 30.0 + i.toDouble(),
                        salePrice: 29.0 + i.toDouble(),
                        subunits: 24,
                        unitName: '{amount, plural, one {box} other {boxes}}',
                        subunitName:
                            '{amount, plural, one {unit} other {units}}',
                      ),
                  ],
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));
          final listFinder = find.byType(Scrollable);
          final showMoreButton = find.text('Show more');
          await tester.scrollUntilVisible(
            showMoreButton,
            500,
            scrollable: listFinder.last,
          );
          expect(showMoreButton, findsOneWidget);
          await tester.tap(showMoreButton);
          verify(() => chatBloc.add(ChatToggleMessageExpand(messageId: 8)));
        },
      );

      testWidgets(
        'should render an expanded product messages correctly, with more than 3 elements, should be able to click show less button',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.product(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  expand: true,
                  products: [
                    for (int i = 0; i < 10; i++)
                      Product(
                        sku: '123$i',
                        name: 'test product without name $i',
                        price: 30.0 + i.toDouble(),
                        salePrice: 29.0 + i.toDouble(),
                        subunits: 24,
                        unitName: '{amount, plural, one {box} other {boxes}}',
                        subunitName:
                            '{amount, plural, one {unit} other {units}}',
                      ),
                  ],
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));
          expect(find.text('test product without name 9'), findsOneWidget);
          final showLessButton = find.text('Show less');
          expect(showLessButton, findsOneWidget);
          await tester.tap(showLessButton);
          verify(() => chatBloc.add(ChatToggleMessageExpand(messageId: 8)));
        },
      );

      testWidgets(
        'should render product carousel with one element correctly and be able to add, edit and remove units',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.carousel(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  products: [
                    Product(
                      sku: '123',
                      name: 'test product without name',
                      price: 30.0,
                      salePrice: 29.0,
                      subunits: 24,
                      unitName: '{amount, plural, one {box} other {boxes}}',
                      subunitName: '{amount, plural, one {unit} other {units}}',
                    ),
                  ],
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));

          expect(find.text('test product without name'), findsOneWidget);
          expect(find.text('0 boxes'), findsOneWidget);
          expect(find.text('0 units'), findsOneWidget);

          final addFinder = find.byIcon(Icons.add);
          final removeFinder = find.byIcon(Icons.remove);
          final textFieldFinder = find.byType(TextField);
          expect(addFinder, findsNWidgets(2));
          expect(removeFinder, findsNWidgets(2));
          expect(textFieldFinder, findsNWidgets(2));
          await tester.tap(addFinder.first);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.unit,
                quantity: 1,
              ),
            ),
          ).called(1);

          await tester.tap(removeFinder.first);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.unit,
                quantity: -1.0,
              ),
            ),
          ).called(1);

          await tester.tap(addFinder.last);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.subunit,
                quantity: 1,
              ),
            ),
          ).called(1);

          await tester.tap(removeFinder.last);
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.subunit,
                quantity: -1.0,
              ),
            ),
          ).called(1);

          // Verify text edition
          await tester.pumpAndSettle();
          await tester.enterText(textFieldFinder.first, '3');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.unit,
                quantity: 3.0,
              ),
            ),
          ).called(1);

          await tester.enterText(textFieldFinder.last, '3');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await tester.pumpAndSettle();
          verify(
            () => chatBloc.add(
              ChatUpdateProductQuantity(
                messageId: 8,
                productSku: '123',
                unitType: UnitType.subunit,
                quantity: 3.0,
              ),
            ),
          ).called(1);
        },
      );

      testWidgets(
        'should render product carousel and product message in portrait mode correctly',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage.carousel(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  products: [
                    Product(
                      sku: '123',
                      name: 'test product without name',
                      price: 30.0,
                      salePrice: 29.0,
                      subunits: 24,
                      unitName: '{amount, plural, one {box} other {boxes}}',
                      subunitName: '{amount, plural, one {unit} other {units}}',
                    ),
                  ],
                ),
                ChatMessage.product(
                  id: 9,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  products: [
                    Product(
                      sku: '123',
                      name: 'product message',
                      price: 30.0,
                      salePrice: 29.0,
                      subunits: 24,
                      unitName: '{amount, plural, one {box} other {boxes}}',
                      subunitName: '{amount, plural, one {unit} other {units}}',
                    ),
                  ],
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          tester.view.physicalSize = const Size(600, 800);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
          });

          await tester.pumpWidget(TestWidget(blocs: blocs));

          expect(find.text('test product without name'), findsOneWidget);
          expect(find.text('product message'), findsOneWidget);
          expect(find.text('0 boxes'), findsNWidgets(2));
          expect(find.text('0 units'), findsNWidgets(2));

          final addFinder = find.byIcon(Icons.add);
          final removeFinder = find.byIcon(Icons.remove);
          final textFieldFinder = find.byType(TextField);
          expect(addFinder, findsNWidgets(4));
          expect(removeFinder, findsNWidgets(4));
          expect(textFieldFinder, findsNWidgets(4));
        },
      );

      testWidgets(
        'should throw an unimplemented error when a unsupported assistant message is received',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            MessagesState(
              messages: [
                ChatMessage(
                  id: 8,
                  role: MessageRole.assistant,
                  timestamp: clock.now(),
                  content:
                      'This is a very large assistant message designed just for testing the widget of yalo\'s flutter SDK',
                  type: MessageType.unknown,
                ),
              ],
            ),
          );
          when(() => imageBloc.state).thenReturn(ImageState());
          when(() => audioBloc.state).thenReturn(AudioState());

          await tester.pumpWidget(TestWidget(blocs: blocs));
          expect(tester.takeException(), isA<UnimplementedError>());
        },
      );
    });
  });
}

class TestWidget extends StatelessWidget {
  final List<SingleChildWidget> blocs;
  const TestWidget({super.key, required this.blocs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Widget',
      home: MultiBlocProvider(
        providers: blocs,
        child: Scaffold(
          appBar: AppBar(title: Text('Test')),
          body: SafeArea(
            child: Column(children: [Expanded(child: MessageList())]),
          ),
        ),
      ),
    );
  }
}
