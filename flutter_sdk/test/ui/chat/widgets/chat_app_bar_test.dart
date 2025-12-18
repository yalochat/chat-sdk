// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_app_bar/chat_app_bar.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatBloc extends MockBloc<MessagesEvent, MessagesState>
    implements MessagesBloc {}

void main() {
  group(ChatAppBar, () {
    late ChatThemeCubit chatThemeCubit;
    late MessagesBloc messagesBloc;

    setUp(() {
      final imageFile = File('images/test-image.png');
      chatThemeCubit = ChatThemeCubit(
        chatTheme: ChatTheme(
          chatIconImage: FileImage(imageFile),
        ),
      );
      messagesBloc = MockChatBloc();
    });

    group('chat title', () {
      testWidgets(
        'should display title text, subtitle, shop and cart icon buttons when the onPressed handlers are set',
        (tester) async {
          when(() => messagesBloc.state).thenReturn(
            MessagesState(
              userMessage: 'Teeest message',
              chatTitle: 'Test',
              chatStatusText: 'status',
            ),
          );

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ChatThemeCubit>(
                  create: (context) => chatThemeCubit,
                ),
                BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
              ],
              child: TestWidget(onShopPressed: () {}, onCartPressed: () {}),
            ),
          );
          final shopIconFinder = find.byIcon(
            chatThemeCubit.state.shopIcon,
          );

          final cartIconFinder = find.byIcon(
            chatThemeCubit.state.cartIcon,
          );

          final titleTextFinder = find.text('Test');
          final subtitleFinder = find.text('status');

          expect(shopIconFinder, findsOneWidget);
          expect(cartIconFinder, findsOneWidget);
          expect(titleTextFinder, findsOneWidget);
          expect(subtitleFinder, findsOneWidget);
        },
      );
      testWidgets('should display only title text when theres no status', (
        tester,
      ) async {
        when(() => messagesBloc.state).thenReturn(
          MessagesState(
            userMessage: 'Teeest message',
            chatTitle: 'Test',
            chatStatusText: '',
          ),
        );

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
              BlocProvider<MessagesBloc>(create: (context) => messagesBloc),
            ],
            child: TestWidget(onShopPressed: () {}, onCartPressed: () {}),
          ),
        );
        final shopIconFinder = find.byIcon(chatThemeCubit.state.shopIcon);

        final cartIconFinder = find.byIcon(chatThemeCubit.state.cartIcon);

        final titleTextFinder = find.text('Test');
        final subtitleFinder = find.text('status');

        expect(shopIconFinder, findsOneWidget);
        expect(cartIconFinder, findsOneWidget);
        expect(titleTextFinder, findsOneWidget);
        expect(subtitleFinder, isNot(findsOneWidget));
      });
    });
  });
}

class TestWidget extends StatelessWidget {
  final VoidCallback? onShopPressed;
  final VoidCallback? onCartPressed;

  const TestWidget({super.key, this.onShopPressed, this.onCartPressed});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Widget',
      home: Scaffold(
        appBar: ChatAppBar(
          onShopPressed: onShopPressed,
          onCartPressed: onCartPressed,
        ),
        body: SafeArea(
          child: Column(children: [Expanded(child: Container())]),
        ),
      ),
    );
  }
}
