// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:bloc_test/bloc_test.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_state.dart';
import 'package:chat_flutter_sdk/src/ui/chat/widgets/chat_app_bar/chat_app_bar.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatBloc extends MockBloc<ChatEvent, ChatState> implements ChatBloc {}

void main() {
  group(ChatAppBar, () {
    late ChatThemeCubit chatThemeCubit;
    late ChatBloc chatBloc;

    setUp(() {
      chatThemeCubit = ChatThemeCubit(chatTheme: ChatTheme());
      chatBloc = MockChatBloc();
    });

    group('chat title', () {
      testWidgets(
        'should display title text, subtitle, shop and cart icon buttons when the onPressed handlers are set',
        (tester) async {
          when(() => chatBloc.state).thenReturn(
            ChatState(
              userMessage: 'Teeest message',
              chatTitle: 'Test',
              chatStatus: 'status',
            ),
          );

          await tester.pumpWidget(
            MultiBlocProvider(
              providers: [
                BlocProvider<ChatThemeCubit>(
                  create: (context) => chatThemeCubit,
                ),
                BlocProvider<ChatBloc>(create: (context) => chatBloc),
              ],
              child: TestWidget(onShopPressed: () {}, onCartPressed: () {}),
            ),
          );
          final shopIconFinder = find.byIcon(
            chatThemeCubit.state.shopIcon.icon!,
          );

          final cartIconFinder = find.byIcon(
            chatThemeCubit.state.cartIcon.icon!,
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
        when(() => chatBloc.state).thenReturn(
          ChatState(
            userMessage: 'Teeest message',
            chatTitle: 'Test',
            chatStatus: '',
          ),
        );

        await tester.pumpWidget(
          MultiBlocProvider(
            providers: [
              BlocProvider<ChatThemeCubit>(create: (context) => chatThemeCubit),
              BlocProvider<ChatBloc>(create: (context) => chatBloc),
            ],
            child: TestWidget(onShopPressed: () {}, onCartPressed: () {}),
          ),
        );
        final shopIconFinder = find.byIcon(chatThemeCubit.state.shopIcon.icon!);

        final cartIconFinder = find.byIcon(chatThemeCubit.state.cartIcon.icon!);

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
