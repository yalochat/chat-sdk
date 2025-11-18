// Copyright (c) Yalochat, Inc. All rights reserved.

import 'package:drift/drift.dart';


part 'database_service.g.dart';

@DriftDatabase(include: {'chat_message.drift'})
class DatabaseService extends _$DatabaseService {
  DatabaseService(super.e);

  @override
  int get schemaVersion => 1;
}
