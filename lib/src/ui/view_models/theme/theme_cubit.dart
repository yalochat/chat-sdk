// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../ui/theme/chat_theme.dart';

class ChatThemeCubit extends Cubit<ChatTheme> {
  final ChatTheme chatTheme;
  ChatThemeCubit({required this.chatTheme}) : super(chatTheme);
}
