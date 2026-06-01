// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DailyLogsTable extends DailyLogs
    with TableInfo<$DailyLogsTable, DailyLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _flowMeta = const VerificationMeta('flow');
  @override
  late final GeneratedColumn<int> flow = GeneratedColumn<int>(
    'flow',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _symptomsMeta = const VerificationMeta(
    'symptoms',
  );
  @override
  late final GeneratedColumn<String> symptoms = GeneratedColumn<String>(
    'symptoms',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _moodMeta = const VerificationMeta('mood');
  @override
  late final GeneratedColumn<String> mood = GeneratedColumn<String>(
    'mood',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _basalBodyTemperatureMeta =
      const VerificationMeta('basalBodyTemperature');
  @override
  late final GeneratedColumn<double> basalBodyTemperature =
      GeneratedColumn<double>(
        'basal_body_temperature',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sexualActivityMeta = const VerificationMeta(
    'sexualActivity',
  );
  @override
  late final GeneratedColumn<bool> sexualActivity = GeneratedColumn<bool>(
    'sexual_activity',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sexual_activity" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    flow,
    symptoms,
    mood,
    basalBodyTemperature,
    sexualActivity,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('flow')) {
      context.handle(
        _flowMeta,
        flow.isAcceptableOrUnknown(data['flow']!, _flowMeta),
      );
    }
    if (data.containsKey('symptoms')) {
      context.handle(
        _symptomsMeta,
        symptoms.isAcceptableOrUnknown(data['symptoms']!, _symptomsMeta),
      );
    }
    if (data.containsKey('mood')) {
      context.handle(
        _moodMeta,
        mood.isAcceptableOrUnknown(data['mood']!, _moodMeta),
      );
    }
    if (data.containsKey('basal_body_temperature')) {
      context.handle(
        _basalBodyTemperatureMeta,
        basalBodyTemperature.isAcceptableOrUnknown(
          data['basal_body_temperature']!,
          _basalBodyTemperatureMeta,
        ),
      );
    }
    if (data.containsKey('sexual_activity')) {
      context.handle(
        _sexualActivityMeta,
        sexualActivity.isAcceptableOrUnknown(
          data['sexual_activity']!,
          _sexualActivityMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyLog(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      flow: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}flow'],
      )!,
      symptoms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}symptoms'],
      )!,
      mood: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mood'],
      ),
      basalBodyTemperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}basal_body_temperature'],
      ),
      sexualActivity: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sexual_activity'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DailyLogsTable createAlias(String alias) {
    return $DailyLogsTable(attachedDatabase, alias);
  }
}

class DailyLog extends DataClass implements Insertable<DailyLog> {
  final DateTime date;
  final int flow;
  final String symptoms;
  final String? mood;
  final double? basalBodyTemperature;
  final bool sexualActivity;
  final String? notes;
  const DailyLog({
    required this.date,
    required this.flow,
    required this.symptoms,
    this.mood,
    this.basalBodyTemperature,
    required this.sexualActivity,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['flow'] = Variable<int>(flow);
    map['symptoms'] = Variable<String>(symptoms);
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    if (!nullToAbsent || basalBodyTemperature != null) {
      map['basal_body_temperature'] = Variable<double>(basalBodyTemperature);
    }
    map['sexual_activity'] = Variable<bool>(sexualActivity);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DailyLogsCompanion toCompanion(bool nullToAbsent) {
    return DailyLogsCompanion(
      date: Value(date),
      flow: Value(flow),
      symptoms: Value(symptoms),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      basalBodyTemperature: basalBodyTemperature == null && nullToAbsent
          ? const Value.absent()
          : Value(basalBodyTemperature),
      sexualActivity: Value(sexualActivity),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DailyLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyLog(
      date: serializer.fromJson<DateTime>(json['date']),
      flow: serializer.fromJson<int>(json['flow']),
      symptoms: serializer.fromJson<String>(json['symptoms']),
      mood: serializer.fromJson<String?>(json['mood']),
      basalBodyTemperature: serializer.fromJson<double?>(
        json['basalBodyTemperature'],
      ),
      sexualActivity: serializer.fromJson<bool>(json['sexualActivity']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'flow': serializer.toJson<int>(flow),
      'symptoms': serializer.toJson<String>(symptoms),
      'mood': serializer.toJson<String?>(mood),
      'basalBodyTemperature': serializer.toJson<double?>(basalBodyTemperature),
      'sexualActivity': serializer.toJson<bool>(sexualActivity),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DailyLog copyWith({
    DateTime? date,
    int? flow,
    String? symptoms,
    Value<String?> mood = const Value.absent(),
    Value<double?> basalBodyTemperature = const Value.absent(),
    bool? sexualActivity,
    Value<String?> notes = const Value.absent(),
  }) => DailyLog(
    date: date ?? this.date,
    flow: flow ?? this.flow,
    symptoms: symptoms ?? this.symptoms,
    mood: mood.present ? mood.value : this.mood,
    basalBodyTemperature: basalBodyTemperature.present
        ? basalBodyTemperature.value
        : this.basalBodyTemperature,
    sexualActivity: sexualActivity ?? this.sexualActivity,
    notes: notes.present ? notes.value : this.notes,
  );
  DailyLog copyWithCompanion(DailyLogsCompanion data) {
    return DailyLog(
      date: data.date.present ? data.date.value : this.date,
      flow: data.flow.present ? data.flow.value : this.flow,
      symptoms: data.symptoms.present ? data.symptoms.value : this.symptoms,
      mood: data.mood.present ? data.mood.value : this.mood,
      basalBodyTemperature: data.basalBodyTemperature.present
          ? data.basalBodyTemperature.value
          : this.basalBodyTemperature,
      sexualActivity: data.sexualActivity.present
          ? data.sexualActivity.value
          : this.sexualActivity,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyLog(')
          ..write('date: $date, ')
          ..write('flow: $flow, ')
          ..write('symptoms: $symptoms, ')
          ..write('mood: $mood, ')
          ..write('basalBodyTemperature: $basalBodyTemperature, ')
          ..write('sexualActivity: $sexualActivity, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    flow,
    symptoms,
    mood,
    basalBodyTemperature,
    sexualActivity,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyLog &&
          other.date == this.date &&
          other.flow == this.flow &&
          other.symptoms == this.symptoms &&
          other.mood == this.mood &&
          other.basalBodyTemperature == this.basalBodyTemperature &&
          other.sexualActivity == this.sexualActivity &&
          other.notes == this.notes);
}

class DailyLogsCompanion extends UpdateCompanion<DailyLog> {
  final Value<DateTime> date;
  final Value<int> flow;
  final Value<String> symptoms;
  final Value<String?> mood;
  final Value<double?> basalBodyTemperature;
  final Value<bool> sexualActivity;
  final Value<String?> notes;
  final Value<int> rowid;
  const DailyLogsCompanion({
    this.date = const Value.absent(),
    this.flow = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.mood = const Value.absent(),
    this.basalBodyTemperature = const Value.absent(),
    this.sexualActivity = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyLogsCompanion.insert({
    required DateTime date,
    this.flow = const Value.absent(),
    this.symptoms = const Value.absent(),
    this.mood = const Value.absent(),
    this.basalBodyTemperature = const Value.absent(),
    this.sexualActivity = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyLog> custom({
    Expression<DateTime>? date,
    Expression<int>? flow,
    Expression<String>? symptoms,
    Expression<String>? mood,
    Expression<double>? basalBodyTemperature,
    Expression<bool>? sexualActivity,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (flow != null) 'flow': flow,
      if (symptoms != null) 'symptoms': symptoms,
      if (mood != null) 'mood': mood,
      if (basalBodyTemperature != null)
        'basal_body_temperature': basalBodyTemperature,
      if (sexualActivity != null) 'sexual_activity': sexualActivity,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyLogsCompanion copyWith({
    Value<DateTime>? date,
    Value<int>? flow,
    Value<String>? symptoms,
    Value<String?>? mood,
    Value<double?>? basalBodyTemperature,
    Value<bool>? sexualActivity,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return DailyLogsCompanion(
      date: date ?? this.date,
      flow: flow ?? this.flow,
      symptoms: symptoms ?? this.symptoms,
      mood: mood ?? this.mood,
      basalBodyTemperature: basalBodyTemperature ?? this.basalBodyTemperature,
      sexualActivity: sexualActivity ?? this.sexualActivity,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (flow.present) {
      map['flow'] = Variable<int>(flow.value);
    }
    if (symptoms.present) {
      map['symptoms'] = Variable<String>(symptoms.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (basalBodyTemperature.present) {
      map['basal_body_temperature'] = Variable<double>(
        basalBodyTemperature.value,
      );
    }
    if (sexualActivity.present) {
      map['sexual_activity'] = Variable<bool>(sexualActivity.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyLogsCompanion(')
          ..write('date: $date, ')
          ..write('flow: $flow, ')
          ..write('symptoms: $symptoms, ')
          ..write('mood: $mood, ')
          ..write('basalBodyTemperature: $basalBodyTemperature, ')
          ..write('sexualActivity: $sexualActivity, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [dailyLogs, appSettings];
}

typedef $$DailyLogsTableCreateCompanionBuilder =
    DailyLogsCompanion Function({
      required DateTime date,
      Value<int> flow,
      Value<String> symptoms,
      Value<String?> mood,
      Value<double?> basalBodyTemperature,
      Value<bool> sexualActivity,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$DailyLogsTableUpdateCompanionBuilder =
    DailyLogsCompanion Function({
      Value<DateTime> date,
      Value<int> flow,
      Value<String> symptoms,
      Value<String?> mood,
      Value<double?> basalBodyTemperature,
      Value<bool> sexualActivity,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$DailyLogsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get flow => $composableBuilder(
    column: $table.flow,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basalBodyTemperature => $composableBuilder(
    column: $table.basalBodyTemperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sexualActivity => $composableBuilder(
    column: $table.sexualActivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get flow => $composableBuilder(
    column: $table.flow,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get symptoms => $composableBuilder(
    column: $table.symptoms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basalBodyTemperature => $composableBuilder(
    column: $table.basalBodyTemperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sexualActivity => $composableBuilder(
    column: $table.sexualActivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyLogsTable> {
  $$DailyLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get flow =>
      $composableBuilder(column: $table.flow, builder: (column) => column);

  GeneratedColumn<String> get symptoms =>
      $composableBuilder(column: $table.symptoms, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<double> get basalBodyTemperature => $composableBuilder(
    column: $table.basalBodyTemperature,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sexualActivity => $composableBuilder(
    column: $table.sexualActivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DailyLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyLogsTable,
          DailyLog,
          $$DailyLogsTableFilterComposer,
          $$DailyLogsTableOrderingComposer,
          $$DailyLogsTableAnnotationComposer,
          $$DailyLogsTableCreateCompanionBuilder,
          $$DailyLogsTableUpdateCompanionBuilder,
          (DailyLog, BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLog>),
          DailyLog,
          PrefetchHooks Function()
        > {
  $$DailyLogsTableTableManager(_$AppDatabase db, $DailyLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> date = const Value.absent(),
                Value<int> flow = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<double?> basalBodyTemperature = const Value.absent(),
                Value<bool> sexualActivity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLogsCompanion(
                date: date,
                flow: flow,
                symptoms: symptoms,
                mood: mood,
                basalBodyTemperature: basalBodyTemperature,
                sexualActivity: sexualActivity,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required DateTime date,
                Value<int> flow = const Value.absent(),
                Value<String> symptoms = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<double?> basalBodyTemperature = const Value.absent(),
                Value<bool> sexualActivity = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyLogsCompanion.insert(
                date: date,
                flow: flow,
                symptoms: symptoms,
                mood: mood,
                basalBodyTemperature: basalBodyTemperature,
                sexualActivity: sexualActivity,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyLogsTable,
      DailyLog,
      $$DailyLogsTableFilterComposer,
      $$DailyLogsTableOrderingComposer,
      $$DailyLogsTableAnnotationComposer,
      $$DailyLogsTableCreateCompanionBuilder,
      $$DailyLogsTableUpdateCompanionBuilder,
      (DailyLog, BaseReferences<_$AppDatabase, $DailyLogsTable, DailyLog>),
      DailyLog,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
