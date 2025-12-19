// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/l10n/yalo_sdk_localizations.dart';
import 'package:chat_flutter_sdk/src/common/translation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Translation extension tests', () {
    late BuildContext context;

    Widget createTestWidget({
      required Widget child,
      YaloSdkLocalizations? loc,
      required Locale locale,
    }) {
      return MaterialApp(
        localizationsDelegates: [
          YaloSdkLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [locale],
        locale: locale,
        home: Builder(builder: (context) => child),
      );
    }

    tearDown(() {
      context.cleanTranslate();
    });

    testWidgets(
      'translate should display locale in english with flutter localization',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            locale: Locale('en', 'US'),
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return Container();
              },
            ),
          ),
        );

        final result = context.translate.takePhoto;

        expect(result, 'Take a photo');
      },
    );

    testWidgets(
      'translate should switch locale correctly with flutter localization',
      (tester) async {
        await tester.pumpWidget(
          createTestWidget(
            locale: Locale('es', 'CO'),
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return Container();
              },
            ),
          ),
        );

        final result = context.translate.takePhoto;

        expect(result, 'Tomar foto');
      },
    );
  });
}
