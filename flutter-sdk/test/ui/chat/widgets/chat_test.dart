// Copyright (c) Yalochat, Inc. All rights reserved.

import 'dart:async';

import 'package:yalo_chat_flutter_sdk/data/services/client/yalo_chat_client.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/chat_app_bar/chat_app_bar.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/chat_input/chat_input.dart';
import 'package:yalo_chat_flutter_sdk/src/ui/chat/widgets/message_list/message_list.dart';
import 'package:yalo_chat_flutter_sdk/ui/chat/widgets/chat.dart';
import 'package:yalo_chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:record/record.dart';

class MockRecordPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements RecordPlatform {}

void main() {
  group(Chat, () {
    late YaloChatClient client;

    setUpAll(() {
      final MockRecordPlatform mockRecordPlatform = MockRecordPlatform();
      RecordPlatform.instance = mockRecordPlatform;
      when(() => mockRecordPlatform.create(any())).thenAnswer((_) async {});
      when(
        () => mockRecordPlatform.getAmplitude(any()),
      ).thenAnswer((_) async => Amplitude(current: -160.0, max: -160.0));
      when(() => mockRecordPlatform.dispose(any())).thenAnswer((_) async {});
      when(
        () => mockRecordPlatform.onStateChanged(any()),
      ).thenAnswer((_) => const Stream.empty());
    });

    setUp(() {
      client = YaloChatClient(
        name: 'Test',
        channelId: 'ch-1',
        organizationId: 'org-1',
      );
    });

    Future<void> pumpChat(
      WidgetTester tester, {
      PreferredSizeWidget? appBar,
      bool showAttachmentButton = true,
      VoidCallback? onShopPressed,
      VoidCallback? onCartPressed,
      ChatTheme theme = const ChatTheme(),
      String? openContext,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Chat(
            client: client,
            appBar: appBar,
            showAttachmentButton: showAttachmentButton,
            onShopPressed: onShopPressed,
            onCartPressed: onCartPressed,
            theme: theme,
            openContext: openContext,
          ),
        ),
      );
      await tester.pump(Duration.zero);
      await tester.pump(Duration.zero);
    }

    Future<void> disposeChat(WidgetTester tester) async {
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    }

    group('structure', () {
      testWidgets('should render Scaffold with default ChatAppBar', (
        tester,
      ) async {
        await pumpChat(tester);

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(ChatAppBar), findsOneWidget);

        await disposeChat(tester);
      });

      testWidgets('should use custom appBar when provided', (tester) async {
        await pumpChat(
          tester,
          appBar: AppBar(title: const Text('Custom Title')),
        );

        expect(find.text('Custom Title'), findsOneWidget);
        expect(find.byType(ChatAppBar), findsNothing);

        await disposeChat(tester);
      });

      testWidgets('should render ChatInput and MessageList', (tester) async {
        await pumpChat(tester);

        expect(find.byType(ChatInput), findsOneWidget);
        expect(find.byType(MessageList), findsOneWidget);

        await disposeChat(tester);
      });
    });

    group('theme', () {
      testWidgets('should apply background color from theme', (tester) async {
        await pumpChat(tester, theme: ChatTheme(backgroundColor: Colors.red));

        final Scaffold scaffold = tester.widget<Scaffold>(
          find.byType(Scaffold),
        );
        expect(scaffold.backgroundColor, equals(Colors.red));

        await disposeChat(tester);
      });
    });

    group('app bar callbacks', () {
      testWidgets('should show shop icon when onShopPressed is provided', (
        tester,
      ) async {
        await pumpChat(tester, onShopPressed: () {});

        expect(find.byIcon(const ChatTheme().shopIcon), findsOneWidget);

        await disposeChat(tester);
      });

      testWidgets('should show cart icon when onCartPressed is provided', (
        tester,
      ) async {
        await pumpChat(tester, onCartPressed: () {});

        expect(find.byIcon(const ChatTheme().cartIcon), findsOneWidget);

        await disposeChat(tester);
      });

      testWidgets(
        'should not show shop and cart icons when callbacks are null',
        (tester) async {
          await pumpChat(tester);

          expect(find.byIcon(const ChatTheme().shopIcon), findsNothing);
          expect(find.byIcon(const ChatTheme().cartIcon), findsNothing);

          await disposeChat(tester);
        },
      );

      testWidgets('should invoke onShopPressed when shop icon is tapped', (
        tester,
      ) async {
        bool shopPressed = false;
        await pumpChat(tester, onShopPressed: () => shopPressed = true);

        await tester.tap(find.byIcon(const ChatTheme().shopIcon));
        expect(shopPressed, isTrue);

        await disposeChat(tester);
      });

      testWidgets('should invoke onCartPressed when cart icon is tapped', (
        tester,
      ) async {
        bool cartPressed = false;
        await pumpChat(tester, onCartPressed: () => cartPressed = true);

        await tester.tap(find.byIcon(const ChatTheme().cartIcon));
        expect(cartPressed, isTrue);

        await disposeChat(tester);
      });
    });

    group('opening context', () {
      testWidgets('should default openContext to null', (tester) async {
        await pumpChat(tester);

        final Chat chat = tester.widget<Chat>(find.byType(Chat));
        expect(chat.openContext, isNull);

        await disposeChat(tester);
      });

      testWidgets('should expose the provided opening context', (tester) async {
        await pumpChat(tester, openContext: 'product page of product 123');

        final Chat chat = tester.widget<Chat>(find.byType(Chat));
        expect(chat.openContext, equals('product page of product 123'));

        await disposeChat(tester);
      });
    });

    group('chat input', () {
      testWidgets(
        'should show attachment button when showAttachmentButton is true',
        (tester) async {
          await pumpChat(tester, showAttachmentButton: true);

          expect(find.byKey(const Key('AttachmentButton')), findsOneWidget);

          await disposeChat(tester);
        },
      );

      testWidgets(
        'should not show attachment button when showAttachmentButton is false',
        (tester) async {
          await pumpChat(tester, showAttachmentButton: false);

          expect(find.byKey(const Key('AttachmentButton')), findsNothing);

          await disposeChat(tester);
        },
      );
    });
  });
}
