// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/view_models/chat/chat_cubit.dart';
import 'package:chat_flutter_sdk/src/ui/view_models/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

import '../../ui/theme/chat_theme.dart';


List<SingleChildWidget> chatProviders(ChatTheme theme) {
  return [
    BlocProvider<ChatCubit>(
      create: (context) => ChatCubit(),
    ),
    BlocProvider<ChatThemeCubit>(
      create: (context) => ChatThemeCubit(chatTheme: theme),
    ),
  ];
}
