// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ChatThemeCubit extends Cubit<ChatTheme> {
  final ChatTheme chatTheme;
  ChatThemeCubit({required this.chatTheme}) : super(chatTheme);
}
