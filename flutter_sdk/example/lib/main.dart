// Copyright (c) Yalochat, Inc. All rights

import 'package:chat_flutter_sdk/data/services/yalo_chat_client.dart';
import 'package:chat_flutter_sdk/ui/chat/widgets/chat.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '${record.level.name}: ${record.time}: ${record.message} ${record.error ?? ''}',
    );
  });
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyRoutedApp());
}

final class MyRoutedApp extends StatelessWidget {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => MyApp(),
        routes: <RouteBase>[
          GoRoute(
            path: 'chat',
            builder: (context, _) {
              final themeData = Theme.of(context);
              return Chat(
                client: YaloChatClient(name: "Chat test", flowKey: "1230487123041234"),
                theme: ChatTheme.fromThemeData(
                  themeData,
                  ChatTheme(
                    chatIconImage: const AssetImage(
                      'assets/images/oris-icon.png',
                    ),
                  ),
                ),
                onShopPressed: () {},
                onCartPressed: () {},
              );
            },
          ),
        ],
      ),
    ],
  );

  MyRoutedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(routerConfig: router);
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  void _handleChatClick(BuildContext context) {
    context.go("/chat");
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Sample application for chat")),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _handleChatClick(context),
          child: const Icon(Icons.message),
        ),
      ),
    );
  }
}
