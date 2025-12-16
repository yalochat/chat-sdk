// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:chat_flutter_sdk/l10n/yalo_sdk_localizations.g.dart';
import 'package:chat_flutter_sdk/l10n/yalo_sdk_localizations_en.g.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/audio/audio_repository_local.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/chat_message/chat_message_repository_local.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository.dart';
import 'package:chat_flutter_sdk/src/data/repositories/image/image_repository_local.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service.dart';
import 'package:chat_flutter_sdk/src/data/services/audio/audio_service_file.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service.dart';
import 'package:chat_flutter_sdk/src/data/services/camera/camera_service_file.dart';
import 'package:chat_flutter_sdk/src/data/services/database/database_service.dart'
    show DatabaseService;
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/audio/audio_event.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/image/image_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_bloc.dart';
import 'package:chat_flutter_sdk/src/ui/chat/view_models/messages/messages_event.dart';
import 'package:chat_flutter_sdk/src/ui/theme/view_models/theme_cubit.dart';
import 'package:chat_flutter_sdk/ui/theme/chat_theme.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

List<SingleChildWidget> repositoryProviders(BuildContext context) {
  final localizations =
      YaloSdkLocalizations.of(context) ?? YaloSdkLocalizationsEn();
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
      create: (_) => AudioServiceFile(),
      dispose: (_, audioService) => audioService.dispose(),
    ),

    Provider<YaloSdkLocalizations>(create: (_) => localizations),
    Provider<CameraService>(create: (_) => CameraServiceFile()),
    RepositoryProvider<ImageRepository>(
      create: (context) => ImageRepositoryLocal(
        context.read<CameraService>(),
        getApplicationSupportDirectory,
      ),
    ),
    RepositoryProvider<AudioRepository>(
      create: (context) => AudioRepositoryLocal(
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
    BlocProvider<MessagesBloc>(
      create: (context) => MessagesBloc(
        name: name,
        chatMessageRepository: context.read<ChatMessageRepository>(),
        imageRepository: context.read<ImageRepository>(),
      )..add(ChatLoadMessages(direction: PageDirection.initial)),
    ),
    BlocProvider<AudioBloc>(
      create: (context) =>
          AudioBloc(audioRepository: context.read<AudioRepository>())
            ..add(AudioAmplitudeSubscribe())
            ..add(AudioCompletedSubscribe()),
    ),
    BlocProvider<ImageBloc>(
      create: (context) =>
          ImageBloc(imageRepository: context.read<ImageRepository>()),
    ),
    BlocProvider<ChatThemeCubit>(
      create: (context) => ChatThemeCubit(chatTheme: theme),
    ),
  ];
}
