// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:drift/drift.dart';

part 'database_service.g.dart';

@DriftDatabase(include: {'chat_message.drift'})
class DatabaseService extends _$DatabaseService {
  static DatabaseService? _instance;
  DatabaseService._(super.e);

  factory DatabaseService(QueryExecutor e) {
    _instance ??= DatabaseService._(e);

    return _instance!;
  }

  @override
  Future<void> close() async {
    await super.close();
    _instance = null;
  }

  @override
  int get schemaVersion => 1;
}
