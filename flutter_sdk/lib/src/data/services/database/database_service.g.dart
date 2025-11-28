// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_service.dart';

// ignore_for_file: type=lint
class ChatMessage extends Table with TableInfo<ChatMessage, ChatMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatMessage(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY',
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _amplitudesMeta = const VerificationMeta(
    'amplitudes',
  );
  late final GeneratedColumn<String> amplitudes = GeneratedColumn<String>(
    'amplitudes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _durationMeta = const VerificationMeta(
    'duration',
  );
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
    'duration',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    role,
    content,
    type,
    status,
    fileName,
    amplitudes,
    duration,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_message';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChatMessageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('amplitudes')) {
      context.handle(
        _amplitudesMeta,
        amplitudes.isAcceptableOrUnknown(data['amplitudes']!, _amplitudesMeta),
      );
    }
    if (data.containsKey('duration')) {
      context.handle(
        _durationMeta,
        duration.isAcceptableOrUnknown(data['duration']!, _durationMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      amplitudes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amplitudes'],
      ),
      duration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  ChatMessage createAlias(String alias) {
    return ChatMessage(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ChatMessageData extends DataClass implements Insertable<ChatMessageData> {
  final int id;
  final String role;
  final String content;
  final String type;
  final String status;
  final String? fileName;
  final String? amplitudes;
  final int? duration;
  final int timestamp;
  const ChatMessageData({
    required this.id,
    required this.role,
    required this.content,
    required this.type,
    required this.status,
    this.fileName,
    this.amplitudes,
    this.duration,
    required this.timestamp,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['type'] = Variable<String>(type);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    if (!nullToAbsent || amplitudes != null) {
      map['amplitudes'] = Variable<String>(amplitudes);
    }
    if (!nullToAbsent || duration != null) {
      map['duration'] = Variable<int>(duration);
    }
    map['timestamp'] = Variable<int>(timestamp);
    return map;
  }

  ChatMessageCompanion toCompanion(bool nullToAbsent) {
    return ChatMessageCompanion(
      id: Value(id),
      role: Value(role),
      content: Value(content),
      type: Value(type),
      status: Value(status),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      amplitudes: amplitudes == null && nullToAbsent
          ? const Value.absent()
          : Value(amplitudes),
      duration: duration == null && nullToAbsent
          ? const Value.absent()
          : Value(duration),
      timestamp: Value(timestamp),
    );
  }

  factory ChatMessageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageData(
      id: serializer.fromJson<int>(json['id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      type: serializer.fromJson<String>(json['type']),
      status: serializer.fromJson<String>(json['status']),
      fileName: serializer.fromJson<String?>(json['file_name']),
      amplitudes: serializer.fromJson<String?>(json['amplitudes']),
      duration: serializer.fromJson<int?>(json['duration']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'type': serializer.toJson<String>(type),
      'status': serializer.toJson<String>(status),
      'file_name': serializer.toJson<String?>(fileName),
      'amplitudes': serializer.toJson<String?>(amplitudes),
      'duration': serializer.toJson<int?>(duration),
      'timestamp': serializer.toJson<int>(timestamp),
    };
  }

  ChatMessageData copyWith({
    int? id,
    String? role,
    String? content,
    String? type,
    String? status,
    Value<String?> fileName = const Value.absent(),
    Value<String?> amplitudes = const Value.absent(),
    Value<int?> duration = const Value.absent(),
    int? timestamp,
  }) => ChatMessageData(
    id: id ?? this.id,
    role: role ?? this.role,
    content: content ?? this.content,
    type: type ?? this.type,
    status: status ?? this.status,
    fileName: fileName.present ? fileName.value : this.fileName,
    amplitudes: amplitudes.present ? amplitudes.value : this.amplitudes,
    duration: duration.present ? duration.value : this.duration,
    timestamp: timestamp ?? this.timestamp,
  );
  ChatMessageData copyWithCompanion(ChatMessageCompanion data) {
    return ChatMessageData(
      id: data.id.present ? data.id.value : this.id,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      type: data.type.present ? data.type.value : this.type,
      status: data.status.present ? data.status.value : this.status,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      amplitudes: data.amplitudes.present
          ? data.amplitudes.value
          : this.amplitudes,
      duration: data.duration.present ? data.duration.value : this.duration,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageData(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('fileName: $fileName, ')
          ..write('amplitudes: $amplitudes, ')
          ..write('duration: $duration, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    role,
    content,
    type,
    status,
    fileName,
    amplitudes,
    duration,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageData &&
          other.id == this.id &&
          other.role == this.role &&
          other.content == this.content &&
          other.type == this.type &&
          other.status == this.status &&
          other.fileName == this.fileName &&
          other.amplitudes == this.amplitudes &&
          other.duration == this.duration &&
          other.timestamp == this.timestamp);
}

class ChatMessageCompanion extends UpdateCompanion<ChatMessageData> {
  final Value<int> id;
  final Value<String> role;
  final Value<String> content;
  final Value<String> type;
  final Value<String> status;
  final Value<String?> fileName;
  final Value<String?> amplitudes;
  final Value<int?> duration;
  final Value<int> timestamp;
  const ChatMessageCompanion({
    this.id = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.type = const Value.absent(),
    this.status = const Value.absent(),
    this.fileName = const Value.absent(),
    this.amplitudes = const Value.absent(),
    this.duration = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  ChatMessageCompanion.insert({
    this.id = const Value.absent(),
    required String role,
    required String content,
    required String type,
    required String status,
    this.fileName = const Value.absent(),
    this.amplitudes = const Value.absent(),
    this.duration = const Value.absent(),
    required int timestamp,
  }) : role = Value(role),
       content = Value(content),
       type = Value(type),
       status = Value(status),
       timestamp = Value(timestamp);
  static Insertable<ChatMessageData> custom({
    Expression<int>? id,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? type,
    Expression<String>? status,
    Expression<String>? fileName,
    Expression<String>? amplitudes,
    Expression<int>? duration,
    Expression<int>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (type != null) 'type': type,
      if (status != null) 'status': status,
      if (fileName != null) 'file_name': fileName,
      if (amplitudes != null) 'amplitudes': amplitudes,
      if (duration != null) 'duration': duration,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  ChatMessageCompanion copyWith({
    Value<int>? id,
    Value<String>? role,
    Value<String>? content,
    Value<String>? type,
    Value<String>? status,
    Value<String?>? fileName,
    Value<String?>? amplitudes,
    Value<int?>? duration,
    Value<int>? timestamp,
  }) {
    return ChatMessageCompanion(
      id: id ?? this.id,
      role: role ?? this.role,
      content: content ?? this.content,
      type: type ?? this.type,
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      amplitudes: amplitudes ?? this.amplitudes,
      duration: duration ?? this.duration,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (amplitudes.present) {
      map['amplitudes'] = Variable<String>(amplitudes.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageCompanion(')
          ..write('id: $id, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('type: $type, ')
          ..write('status: $status, ')
          ..write('fileName: $fileName, ')
          ..write('amplitudes: $amplitudes, ')
          ..write('duration: $duration, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

abstract class _$DatabaseService extends GeneratedDatabase {
  _$DatabaseService(QueryExecutor e) : super(e);
  $DatabaseServiceManager get managers => $DatabaseServiceManager(this);
  late final ChatMessage chatMessage = ChatMessage(this);
  Selectable<ChatMessageData> getMessagesFirstPage(int limit) {
    return customSelect(
      'SELECT id, role, content, type, status, file_name, amplitudes, duration, timestamp FROM chat_message ORDER BY id DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {chatMessage},
    ).asyncMap(chatMessage.mapFromRow);
  }

  Selectable<ChatMessageData> getMessagesPage(int cursor, int limit) {
    return customSelect(
      'SELECT id, role, content, type, status, file_name, amplitudes, duration, timestamp FROM chat_message WHERE id < ?1 ORDER BY id DESC LIMIT ?2',
      variables: [Variable<int>(cursor), Variable<int>(limit)],
      readsFrom: {chatMessage},
    ).asyncMap(chatMessage.mapFromRow);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [chatMessage];
}

typedef $ChatMessageCreateCompanionBuilder =
    ChatMessageCompanion Function({
      Value<int> id,
      required String role,
      required String content,
      required String type,
      required String status,
      Value<String?> fileName,
      Value<String?> amplitudes,
      Value<int?> duration,
      required int timestamp,
    });
typedef $ChatMessageUpdateCompanionBuilder =
    ChatMessageCompanion Function({
      Value<int> id,
      Value<String> role,
      Value<String> content,
      Value<String> type,
      Value<String> status,
      Value<String?> fileName,
      Value<String?> amplitudes,
      Value<int?> duration,
      Value<int> timestamp,
    });

class $ChatMessageFilterComposer
    extends Composer<_$DatabaseService, ChatMessage> {
  $ChatMessageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amplitudes => $composableBuilder(
    column: $table.amplitudes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );
}

class $ChatMessageOrderingComposer
    extends Composer<_$DatabaseService, ChatMessage> {
  $ChatMessageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amplitudes => $composableBuilder(
    column: $table.amplitudes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duration => $composableBuilder(
    column: $table.duration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ChatMessageAnnotationComposer
    extends Composer<_$DatabaseService, ChatMessage> {
  $ChatMessageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get amplitudes => $composableBuilder(
    column: $table.amplitudes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get duration =>
      $composableBuilder(column: $table.duration, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $ChatMessageTableManager
    extends
        RootTableManager<
          _$DatabaseService,
          ChatMessage,
          ChatMessageData,
          $ChatMessageFilterComposer,
          $ChatMessageOrderingComposer,
          $ChatMessageAnnotationComposer,
          $ChatMessageCreateCompanionBuilder,
          $ChatMessageUpdateCompanionBuilder,
          (
            ChatMessageData,
            BaseReferences<_$DatabaseService, ChatMessage, ChatMessageData>,
          ),
          ChatMessageData,
          PrefetchHooks Function()
        > {
  $ChatMessageTableManager(_$DatabaseService db, ChatMessage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ChatMessageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ChatMessageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ChatMessageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<String?> amplitudes = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
              }) => ChatMessageCompanion(
                id: id,
                role: role,
                content: content,
                type: type,
                status: status,
                fileName: fileName,
                amplitudes: amplitudes,
                duration: duration,
                timestamp: timestamp,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String role,
                required String content,
                required String type,
                required String status,
                Value<String?> fileName = const Value.absent(),
                Value<String?> amplitudes = const Value.absent(),
                Value<int?> duration = const Value.absent(),
                required int timestamp,
              }) => ChatMessageCompanion.insert(
                id: id,
                role: role,
                content: content,
                type: type,
                status: status,
                fileName: fileName,
                amplitudes: amplitudes,
                duration: duration,
                timestamp: timestamp,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ChatMessageProcessedTableManager =
    ProcessedTableManager<
      _$DatabaseService,
      ChatMessage,
      ChatMessageData,
      $ChatMessageFilterComposer,
      $ChatMessageOrderingComposer,
      $ChatMessageAnnotationComposer,
      $ChatMessageCreateCompanionBuilder,
      $ChatMessageUpdateCompanionBuilder,
      (
        ChatMessageData,
        BaseReferences<_$DatabaseService, ChatMessage, ChatMessageData>,
      ),
      ChatMessageData,
      PrefetchHooks Function()
    >;

class $DatabaseServiceManager {
  final _$DatabaseService _db;
  $DatabaseServiceManager(this._db);
  $ChatMessageTableManager get chatMessage =>
      $ChatMessageTableManager(_db, _db.chatMessage);
}
