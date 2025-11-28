// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/domain/models/chat_message/chat_message.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/message_list/message_list.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMessagesBloc extends MockBloc<MessagesEvent, MessagesState> implements MessagesBloc {}

void main() {
  group(MessageList, () {
    late ChatThemeCubit chatThemeCubit;
    late MessagesBloc chatBloc;

    setUp(() {
      chatThemeCubit = ChatThemeCubit(chatTheme: ChatTheme());
      chatBloc = MockMessagesBloc();
    });

    group('user messages', () {
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
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
              BlocProvider<MessagesBloc>(create: (context) => chatBloc),
            ],
            child: const TestWidget(),
          ),
        );

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
          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ChatThemeCubit>(
                  create: (context) => chatThemeCubit,
                ),
                BlocProvider<MessagesBloc>(create: (context) => chatBloc),
              ],
              child: const TestWidget(),
            ),
          );

          final listFinder = find.byType(Scrollable);
          final listItemFinder = find.byKey(ValueKey<int?>(100));
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
        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
              BlocProvider<MessagesBloc>(create: (context) => chatBloc),
            ],
            child: const TestWidget(),
          ),
        );

        final loaderFind = find.byKey(const Key('loading_spinner'));
        expect(loaderFind, findsOneWidget);
      });
    });
  });
}

class TestWidget extends StatelessWidget {
  const TestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Widget',
      home: Scaffold(
        appBar: AppBar(title: Text('Test')),
        body: SafeArea(
          child: Column(children: [Expanded(child: MessageList())]),
        ),
      ),
    );
  }
}
