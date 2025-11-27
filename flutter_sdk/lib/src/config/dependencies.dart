// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository_file.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository_local.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service_record.dart';
import 'package:chat_flutter_sdk/src/data/services/database/database_service.dart'
    show DatabaseService;
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/chat_event.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

List<SingleChildWidget> repositoryProviders() {
  return [
    Provider<DatabaseService>(
      create: (_) => DatabaseService(
        driftDatabase(
          name: 'yalo_sdk_chat',
          native: const DriftNativeOptions(
            databaseDirectory: getApplicationSupportDirectory,
          ),
        ),
      ),
      dispose: (_, databaseService) => databaseService.close(),
    ),
    Provider<AudioService>(
      create: (_) => AudioServiceRecord(),
      dispose: (_, audioService) => audioService.dispose(),
    ),
    RepositoryProvider<AudioRepository>(
      create: (context) => AudioRepositoryFile(
        context.read<AudioService>(),
        getApplicationSupportDirectory,
      ),
    ),
    RepositoryProvider<ChatMessageRepository>(
      create: (context) => ChatMessageRepositoryLocal(
        localDatabaseService: context.read<DatabaseService>(),
      ),
    ),
  ];
}

List<SingleChildWidget> chatProviders(ChatTheme theme, String name) {
  return [
    BlocProvider<ChatBloc>(
      create: (context) =>
          ChatBloc(
              name: name,
              chatMessageRepository: context.read<ChatMessageRepository>(),
              audioRepository: context.read<AudioRepository>(),
            )
            ..add(ChatLoadMessages(direction: PageDirection.initial))
            ..add(ChatAmplitudeSubscribe()),
    ),
    BlocProvider<ChatThemeCubit>(
      create: (context) => ChatThemeCubit(chatTheme: theme),
    ),
  ];
}
