// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> chatProviders(ChatTheme theme, String name) {
  return [
    BlocProvider<ChatBloc>(create: (context) => ChatBloc(name: name)),
    BlocProvider<ChatThemeCubit>(
      create: (context) => ChatThemeCubit(chatTheme: theme),
    ),
  ];
}
