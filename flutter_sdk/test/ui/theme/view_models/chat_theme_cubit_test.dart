// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Theme Cubit tests", () {
    test("should create a cubit with default theme", () {
      final mockTheme = ChatTheme();
      final cubit = ChatThemeCubit(chatTheme: mockTheme);
      expect(cubit.state, equals(mockTheme));
    });
  });
}
