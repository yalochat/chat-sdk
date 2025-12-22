// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/common/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Formatter extension tests', () {
    late BuildContext context;

    Widget createTestWidget({required Widget child, required Locale locale}) {
      return MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [locale],
        locale: locale,
        home: Builder(builder: (context) => child),
      );
    }

    testWidgets(
      'formatCurrency should format double as currency with locale US',
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

        final result = context.formatCurrency(1234.56);
        expect(result, contains('1,234.56'));
      },
    );

    testWidgets('formatNumber should format double as number with locale US', (
      tester,
    ) async {
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

      final result = context.formatNumber(1234.56);

      expect(result, contains('1,234.56'));
    });

    testWidgets(
      'formatCurrency should format double as currency with different supported locale',
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

        final result = context.formatCurrency(1234.56);
        expect(result, contains('1.234,56'));
      },
    );

    testWidgets(
      'formatNumber should format double as number with a different supported locale',
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

        final result = context.formatNumber(1234.56);

        expect(result, contains('1.234,56'));
      },
    );
  });
}
