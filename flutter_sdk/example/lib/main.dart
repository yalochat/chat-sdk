// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/ui/chat/widgets/chat.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp.router(routerConfig: router));
}

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => MyApp(),
      routes: <RouteBase>[
        GoRoute(
          path: 'chat',
          builder: (_, _) {
            return Chat(
              name: "Chat test",
              flowKey: "1230487123041234",
              theme: ChatTheme(),
              onShopPressed: () {},
              onCartPressed: () {},
            );
          },
        ),
      ],
    ),
  ],
);

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
