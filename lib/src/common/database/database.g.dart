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

class $PregnanciesTable extends Pregnancies
    with TableInfo<$PregnanciesTable, Pregnancy> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PregnanciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _lmpDateMeta = const VerificationMeta(
    'lmpDate',
  );
  @override
  late final GeneratedColumn<DateTime> lmpDate = GeneratedColumn<DateTime>(
    'lmp_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cycleLengthDaysMeta = const VerificationMeta(
    'cycleLengthDays',
  );
  @override
  late final GeneratedColumn<int> cycleLengthDays = GeneratedColumn<int>(
    'cycle_length_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(28),
  );
  static const VerificationMeta _ultrasoundDateMeta = const VerificationMeta(
    'ultrasoundDate',
  );
  @override
  late final GeneratedColumn<DateTime> ultrasoundDate =
      GeneratedColumn<DateTime>(
        'ultrasound_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _ultrasoundGestationalAgeDaysMeta =
      const VerificationMeta('ultrasoundGestationalAgeDays');
  @override
  late final GeneratedColumn<int> ultrasoundGestationalAgeDays =
      GeneratedColumn<int>(
        'ultrasound_gestational_age_days',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _eddOverrideMeta = const VerificationMeta(
    'eddOverride',
  );
  @override
  late final GeneratedColumn<DateTime> eddOverride = GeneratedColumn<DateTime>(
    'edd_override',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outcomeMeta = const VerificationMeta(
    'outcome',
  );
  @override
  late final GeneratedColumn<int> outcome = GeneratedColumn<int>(
    'outcome',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outcomeDateMeta = const VerificationMeta(
    'outcomeDate',
  );
  @override
  late final GeneratedColumn<DateTime> outcomeDate = GeneratedColumn<DateTime>(
    'outcome_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    id,
    lmpDate,
    cycleLengthDays,
    ultrasoundDate,
    ultrasoundGestationalAgeDays,
    eddOverride,
    outcome,
    outcomeDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pregnancies';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pregnancy> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('lmp_date')) {
      context.handle(
        _lmpDateMeta,
        lmpDate.isAcceptableOrUnknown(data['lmp_date']!, _lmpDateMeta),
      );
    } else if (isInserting) {
      context.missing(_lmpDateMeta);
    }
    if (data.containsKey('cycle_length_days')) {
      context.handle(
        _cycleLengthDaysMeta,
        cycleLengthDays.isAcceptableOrUnknown(
          data['cycle_length_days']!,
          _cycleLengthDaysMeta,
        ),
      );
    }
    if (data.containsKey('ultrasound_date')) {
      context.handle(
        _ultrasoundDateMeta,
        ultrasoundDate.isAcceptableOrUnknown(
          data['ultrasound_date']!,
          _ultrasoundDateMeta,
        ),
      );
    }
    if (data.containsKey('ultrasound_gestational_age_days')) {
      context.handle(
        _ultrasoundGestationalAgeDaysMeta,
        ultrasoundGestationalAgeDays.isAcceptableOrUnknown(
          data['ultrasound_gestational_age_days']!,
          _ultrasoundGestationalAgeDaysMeta,
        ),
      );
    }
    if (data.containsKey('edd_override')) {
      context.handle(
        _eddOverrideMeta,
        eddOverride.isAcceptableOrUnknown(
          data['edd_override']!,
          _eddOverrideMeta,
        ),
      );
    }
    if (data.containsKey('outcome')) {
      context.handle(
        _outcomeMeta,
        outcome.isAcceptableOrUnknown(data['outcome']!, _outcomeMeta),
      );
    }
    if (data.containsKey('outcome_date')) {
      context.handle(
        _outcomeDateMeta,
        outcomeDate.isAcceptableOrUnknown(
          data['outcome_date']!,
          _outcomeDateMeta,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Pregnancy map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pregnancy(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      lmpDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}lmp_date'],
      )!,
      cycleLengthDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cycle_length_days'],
      )!,
      ultrasoundDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultrasound_date'],
      ),
      ultrasoundGestationalAgeDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ultrasound_gestational_age_days'],
      ),
      eddOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}edd_override'],
      ),
      outcome: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outcome'],
      )!,
      outcomeDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}outcome_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PregnanciesTable createAlias(String alias) {
    return $PregnanciesTable(attachedDatabase, alias);
  }
}

class Pregnancy extends DataClass implements Insertable<Pregnancy> {
  final int id;
  final DateTime lmpDate;
  final int cycleLengthDays;
  final DateTime? ultrasoundDate;
  final int? ultrasoundGestationalAgeDays;
  final DateTime? eddOverride;
  final int outcome;
  final DateTime? outcomeDate;
  final String? notes;
  const Pregnancy({
    required this.id,
    required this.lmpDate,
    required this.cycleLengthDays,
    this.ultrasoundDate,
    this.ultrasoundGestationalAgeDays,
    this.eddOverride,
    required this.outcome,
    this.outcomeDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['lmp_date'] = Variable<DateTime>(lmpDate);
    map['cycle_length_days'] = Variable<int>(cycleLengthDays);
    if (!nullToAbsent || ultrasoundDate != null) {
      map['ultrasound_date'] = Variable<DateTime>(ultrasoundDate);
    }
    if (!nullToAbsent || ultrasoundGestationalAgeDays != null) {
      map['ultrasound_gestational_age_days'] = Variable<int>(
        ultrasoundGestationalAgeDays,
      );
    }
    if (!nullToAbsent || eddOverride != null) {
      map['edd_override'] = Variable<DateTime>(eddOverride);
    }
    map['outcome'] = Variable<int>(outcome);
    if (!nullToAbsent || outcomeDate != null) {
      map['outcome_date'] = Variable<DateTime>(outcomeDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PregnanciesCompanion toCompanion(bool nullToAbsent) {
    return PregnanciesCompanion(
      id: Value(id),
      lmpDate: Value(lmpDate),
      cycleLengthDays: Value(cycleLengthDays),
      ultrasoundDate: ultrasoundDate == null && nullToAbsent
          ? const Value.absent()
          : Value(ultrasoundDate),
      ultrasoundGestationalAgeDays:
          ultrasoundGestationalAgeDays == null && nullToAbsent
          ? const Value.absent()
          : Value(ultrasoundGestationalAgeDays),
      eddOverride: eddOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(eddOverride),
      outcome: Value(outcome),
      outcomeDate: outcomeDate == null && nullToAbsent
          ? const Value.absent()
          : Value(outcomeDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Pregnancy.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pregnancy(
      id: serializer.fromJson<int>(json['id']),
      lmpDate: serializer.fromJson<DateTime>(json['lmpDate']),
      cycleLengthDays: serializer.fromJson<int>(json['cycleLengthDays']),
      ultrasoundDate: serializer.fromJson<DateTime?>(json['ultrasoundDate']),
      ultrasoundGestationalAgeDays: serializer.fromJson<int?>(
        json['ultrasoundGestationalAgeDays'],
      ),
      eddOverride: serializer.fromJson<DateTime?>(json['eddOverride']),
      outcome: serializer.fromJson<int>(json['outcome']),
      outcomeDate: serializer.fromJson<DateTime?>(json['outcomeDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'lmpDate': serializer.toJson<DateTime>(lmpDate),
      'cycleLengthDays': serializer.toJson<int>(cycleLengthDays),
      'ultrasoundDate': serializer.toJson<DateTime?>(ultrasoundDate),
      'ultrasoundGestationalAgeDays': serializer.toJson<int?>(
        ultrasoundGestationalAgeDays,
      ),
      'eddOverride': serializer.toJson<DateTime?>(eddOverride),
      'outcome': serializer.toJson<int>(outcome),
      'outcomeDate': serializer.toJson<DateTime?>(outcomeDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Pregnancy copyWith({
    int? id,
    DateTime? lmpDate,
    int? cycleLengthDays,
    Value<DateTime?> ultrasoundDate = const Value.absent(),
    Value<int?> ultrasoundGestationalAgeDays = const Value.absent(),
    Value<DateTime?> eddOverride = const Value.absent(),
    int? outcome,
    Value<DateTime?> outcomeDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => Pregnancy(
    id: id ?? this.id,
    lmpDate: lmpDate ?? this.lmpDate,
    cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
    ultrasoundDate: ultrasoundDate.present
        ? ultrasoundDate.value
        : this.ultrasoundDate,
    ultrasoundGestationalAgeDays: ultrasoundGestationalAgeDays.present
        ? ultrasoundGestationalAgeDays.value
        : this.ultrasoundGestationalAgeDays,
    eddOverride: eddOverride.present ? eddOverride.value : this.eddOverride,
    outcome: outcome ?? this.outcome,
    outcomeDate: outcomeDate.present ? outcomeDate.value : this.outcomeDate,
    notes: notes.present ? notes.value : this.notes,
  );
  Pregnancy copyWithCompanion(PregnanciesCompanion data) {
    return Pregnancy(
      id: data.id.present ? data.id.value : this.id,
      lmpDate: data.lmpDate.present ? data.lmpDate.value : this.lmpDate,
      cycleLengthDays: data.cycleLengthDays.present
          ? data.cycleLengthDays.value
          : this.cycleLengthDays,
      ultrasoundDate: data.ultrasoundDate.present
          ? data.ultrasoundDate.value
          : this.ultrasoundDate,
      ultrasoundGestationalAgeDays: data.ultrasoundGestationalAgeDays.present
          ? data.ultrasoundGestationalAgeDays.value
          : this.ultrasoundGestationalAgeDays,
      eddOverride: data.eddOverride.present
          ? data.eddOverride.value
          : this.eddOverride,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      outcomeDate: data.outcomeDate.present
          ? data.outcomeDate.value
          : this.outcomeDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pregnancy(')
          ..write('id: $id, ')
          ..write('lmpDate: $lmpDate, ')
          ..write('cycleLengthDays: $cycleLengthDays, ')
          ..write('ultrasoundDate: $ultrasoundDate, ')
          ..write(
            'ultrasoundGestationalAgeDays: $ultrasoundGestationalAgeDays, ',
          )
          ..write('eddOverride: $eddOverride, ')
          ..write('outcome: $outcome, ')
          ..write('outcomeDate: $outcomeDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    lmpDate,
    cycleLengthDays,
    ultrasoundDate,
    ultrasoundGestationalAgeDays,
    eddOverride,
    outcome,
    outcomeDate,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pregnancy &&
          other.id == this.id &&
          other.lmpDate == this.lmpDate &&
          other.cycleLengthDays == this.cycleLengthDays &&
          other.ultrasoundDate == this.ultrasoundDate &&
          other.ultrasoundGestationalAgeDays ==
              this.ultrasoundGestationalAgeDays &&
          other.eddOverride == this.eddOverride &&
          other.outcome == this.outcome &&
          other.outcomeDate == this.outcomeDate &&
          other.notes == this.notes);
}

class PregnanciesCompanion extends UpdateCompanion<Pregnancy> {
  final Value<int> id;
  final Value<DateTime> lmpDate;
  final Value<int> cycleLengthDays;
  final Value<DateTime?> ultrasoundDate;
  final Value<int?> ultrasoundGestationalAgeDays;
  final Value<DateTime?> eddOverride;
  final Value<int> outcome;
  final Value<DateTime?> outcomeDate;
  final Value<String?> notes;
  const PregnanciesCompanion({
    this.id = const Value.absent(),
    this.lmpDate = const Value.absent(),
    this.cycleLengthDays = const Value.absent(),
    this.ultrasoundDate = const Value.absent(),
    this.ultrasoundGestationalAgeDays = const Value.absent(),
    this.eddOverride = const Value.absent(),
    this.outcome = const Value.absent(),
    this.outcomeDate = const Value.absent(),
    this.notes = const Value.absent(),
  });
  PregnanciesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime lmpDate,
    this.cycleLengthDays = const Value.absent(),
    this.ultrasoundDate = const Value.absent(),
    this.ultrasoundGestationalAgeDays = const Value.absent(),
    this.eddOverride = const Value.absent(),
    this.outcome = const Value.absent(),
    this.outcomeDate = const Value.absent(),
    this.notes = const Value.absent(),
  }) : lmpDate = Value(lmpDate);
  static Insertable<Pregnancy> custom({
    Expression<int>? id,
    Expression<DateTime>? lmpDate,
    Expression<int>? cycleLengthDays,
    Expression<DateTime>? ultrasoundDate,
    Expression<int>? ultrasoundGestationalAgeDays,
    Expression<DateTime>? eddOverride,
    Expression<int>? outcome,
    Expression<DateTime>? outcomeDate,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (lmpDate != null) 'lmp_date': lmpDate,
      if (cycleLengthDays != null) 'cycle_length_days': cycleLengthDays,
      if (ultrasoundDate != null) 'ultrasound_date': ultrasoundDate,
      if (ultrasoundGestationalAgeDays != null)
        'ultrasound_gestational_age_days': ultrasoundGestationalAgeDays,
      if (eddOverride != null) 'edd_override': eddOverride,
      if (outcome != null) 'outcome': outcome,
      if (outcomeDate != null) 'outcome_date': outcomeDate,
      if (notes != null) 'notes': notes,
    });
  }

  PregnanciesCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? lmpDate,
    Value<int>? cycleLengthDays,
    Value<DateTime?>? ultrasoundDate,
    Value<int?>? ultrasoundGestationalAgeDays,
    Value<DateTime?>? eddOverride,
    Value<int>? outcome,
    Value<DateTime?>? outcomeDate,
    Value<String?>? notes,
  }) {
    return PregnanciesCompanion(
      id: id ?? this.id,
      lmpDate: lmpDate ?? this.lmpDate,
      cycleLengthDays: cycleLengthDays ?? this.cycleLengthDays,
      ultrasoundDate: ultrasoundDate ?? this.ultrasoundDate,
      ultrasoundGestationalAgeDays:
          ultrasoundGestationalAgeDays ?? this.ultrasoundGestationalAgeDays,
      eddOverride: eddOverride ?? this.eddOverride,
      outcome: outcome ?? this.outcome,
      outcomeDate: outcomeDate ?? this.outcomeDate,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (lmpDate.present) {
      map['lmp_date'] = Variable<DateTime>(lmpDate.value);
    }
    if (cycleLengthDays.present) {
      map['cycle_length_days'] = Variable<int>(cycleLengthDays.value);
    }
    if (ultrasoundDate.present) {
      map['ultrasound_date'] = Variable<DateTime>(ultrasoundDate.value);
    }
    if (ultrasoundGestationalAgeDays.present) {
      map['ultrasound_gestational_age_days'] = Variable<int>(
        ultrasoundGestationalAgeDays.value,
      );
    }
    if (eddOverride.present) {
      map['edd_override'] = Variable<DateTime>(eddOverride.value);
    }
    if (outcome.present) {
      map['outcome'] = Variable<int>(outcome.value);
    }
    if (outcomeDate.present) {
      map['outcome_date'] = Variable<DateTime>(outcomeDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PregnanciesCompanion(')
          ..write('id: $id, ')
          ..write('lmpDate: $lmpDate, ')
          ..write('cycleLengthDays: $cycleLengthDays, ')
          ..write('ultrasoundDate: $ultrasoundDate, ')
          ..write(
            'ultrasoundGestationalAgeDays: $ultrasoundGestationalAgeDays, ',
          )
          ..write('eddOverride: $eddOverride, ')
          ..write('outcome: $outcome, ')
          ..write('outcomeDate: $outcomeDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $KickSessionsTable extends KickSessions
    with TableInfo<$KickSessionsTable, KickSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KickSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pregnancyIdMeta = const VerificationMeta(
    'pregnancyId',
  );
  @override
  late final GeneratedColumn<int> pregnancyId = GeneratedColumn<int>(
    'pregnancy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kickCountMeta = const VerificationMeta(
    'kickCount',
  );
  @override
  late final GeneratedColumn<int> kickCount = GeneratedColumn<int>(
    'kick_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    pregnancyId,
    startTime,
    endTime,
    kickCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kick_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<KickSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pregnancy_id')) {
      context.handle(
        _pregnancyIdMeta,
        pregnancyId.isAcceptableOrUnknown(
          data['pregnancy_id']!,
          _pregnancyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pregnancyIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    }
    if (data.containsKey('kick_count')) {
      context.handle(
        _kickCountMeta,
        kickCount.isAcceptableOrUnknown(data['kick_count']!, _kickCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KickSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KickSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pregnancyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pregnancy_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      ),
      kickCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kick_count'],
      )!,
    );
  }

  @override
  $KickSessionsTable createAlias(String alias) {
    return $KickSessionsTable(attachedDatabase, alias);
  }
}

class KickSession extends DataClass implements Insertable<KickSession> {
  final int id;
  final int pregnancyId;
  final DateTime startTime;
  final DateTime? endTime;
  final int kickCount;
  const KickSession({
    required this.id,
    required this.pregnancyId,
    required this.startTime,
    this.endTime,
    required this.kickCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pregnancy_id'] = Variable<int>(pregnancyId);
    map['start_time'] = Variable<DateTime>(startTime);
    if (!nullToAbsent || endTime != null) {
      map['end_time'] = Variable<DateTime>(endTime);
    }
    map['kick_count'] = Variable<int>(kickCount);
    return map;
  }

  KickSessionsCompanion toCompanion(bool nullToAbsent) {
    return KickSessionsCompanion(
      id: Value(id),
      pregnancyId: Value(pregnancyId),
      startTime: Value(startTime),
      endTime: endTime == null && nullToAbsent
          ? const Value.absent()
          : Value(endTime),
      kickCount: Value(kickCount),
    );
  }

  factory KickSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KickSession(
      id: serializer.fromJson<int>(json['id']),
      pregnancyId: serializer.fromJson<int>(json['pregnancyId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime?>(json['endTime']),
      kickCount: serializer.fromJson<int>(json['kickCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pregnancyId': serializer.toJson<int>(pregnancyId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime?>(endTime),
      'kickCount': serializer.toJson<int>(kickCount),
    };
  }

  KickSession copyWith({
    int? id,
    int? pregnancyId,
    DateTime? startTime,
    Value<DateTime?> endTime = const Value.absent(),
    int? kickCount,
  }) => KickSession(
    id: id ?? this.id,
    pregnancyId: pregnancyId ?? this.pregnancyId,
    startTime: startTime ?? this.startTime,
    endTime: endTime.present ? endTime.value : this.endTime,
    kickCount: kickCount ?? this.kickCount,
  );
  KickSession copyWithCompanion(KickSessionsCompanion data) {
    return KickSession(
      id: data.id.present ? data.id.value : this.id,
      pregnancyId: data.pregnancyId.present
          ? data.pregnancyId.value
          : this.pregnancyId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      kickCount: data.kickCount.present ? data.kickCount.value : this.kickCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KickSession(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('kickCount: $kickCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, pregnancyId, startTime, endTime, kickCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KickSession &&
          other.id == this.id &&
          other.pregnancyId == this.pregnancyId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.kickCount == this.kickCount);
}

class KickSessionsCompanion extends UpdateCompanion<KickSession> {
  final Value<int> id;
  final Value<int> pregnancyId;
  final Value<DateTime> startTime;
  final Value<DateTime?> endTime;
  final Value<int> kickCount;
  const KickSessionsCompanion({
    this.id = const Value.absent(),
    this.pregnancyId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.kickCount = const Value.absent(),
  });
  KickSessionsCompanion.insert({
    this.id = const Value.absent(),
    required int pregnancyId,
    required DateTime startTime,
    this.endTime = const Value.absent(),
    this.kickCount = const Value.absent(),
  }) : pregnancyId = Value(pregnancyId),
       startTime = Value(startTime);
  static Insertable<KickSession> custom({
    Expression<int>? id,
    Expression<int>? pregnancyId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
    Expression<int>? kickCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pregnancyId != null) 'pregnancy_id': pregnancyId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (kickCount != null) 'kick_count': kickCount,
    });
  }

  KickSessionsCompanion copyWith({
    Value<int>? id,
    Value<int>? pregnancyId,
    Value<DateTime>? startTime,
    Value<DateTime?>? endTime,
    Value<int>? kickCount,
  }) {
    return KickSessionsCompanion(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      kickCount: kickCount ?? this.kickCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pregnancyId.present) {
      map['pregnancy_id'] = Variable<int>(pregnancyId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    if (kickCount.present) {
      map['kick_count'] = Variable<int>(kickCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KickSessionsCompanion(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('kickCount: $kickCount')
          ..write(')'))
        .toString();
  }
}

class $ContractionsTable extends Contractions
    with TableInfo<$ContractionsTable, Contraction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pregnancyIdMeta = const VerificationMeta(
    'pregnancyId',
  );
  @override
  late final GeneratedColumn<int> pregnancyId = GeneratedColumn<int>(
    'pregnancy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, pregnancyId, startTime, endTime];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contractions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contraction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pregnancy_id')) {
      context.handle(
        _pregnancyIdMeta,
        pregnancyId.isAcceptableOrUnknown(
          data['pregnancy_id']!,
          _pregnancyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pregnancyIdMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contraction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contraction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pregnancyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pregnancy_id'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_time'],
      )!,
    );
  }

  @override
  $ContractionsTable createAlias(String alias) {
    return $ContractionsTable(attachedDatabase, alias);
  }
}

class Contraction extends DataClass implements Insertable<Contraction> {
  final int id;
  final int pregnancyId;
  final DateTime startTime;
  final DateTime endTime;
  const Contraction({
    required this.id,
    required this.pregnancyId,
    required this.startTime,
    required this.endTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pregnancy_id'] = Variable<int>(pregnancyId);
    map['start_time'] = Variable<DateTime>(startTime);
    map['end_time'] = Variable<DateTime>(endTime);
    return map;
  }

  ContractionsCompanion toCompanion(bool nullToAbsent) {
    return ContractionsCompanion(
      id: Value(id),
      pregnancyId: Value(pregnancyId),
      startTime: Value(startTime),
      endTime: Value(endTime),
    );
  }

  factory Contraction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contraction(
      id: serializer.fromJson<int>(json['id']),
      pregnancyId: serializer.fromJson<int>(json['pregnancyId']),
      startTime: serializer.fromJson<DateTime>(json['startTime']),
      endTime: serializer.fromJson<DateTime>(json['endTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pregnancyId': serializer.toJson<int>(pregnancyId),
      'startTime': serializer.toJson<DateTime>(startTime),
      'endTime': serializer.toJson<DateTime>(endTime),
    };
  }

  Contraction copyWith({
    int? id,
    int? pregnancyId,
    DateTime? startTime,
    DateTime? endTime,
  }) => Contraction(
    id: id ?? this.id,
    pregnancyId: pregnancyId ?? this.pregnancyId,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
  );
  Contraction copyWithCompanion(ContractionsCompanion data) {
    return Contraction(
      id: data.id.present ? data.id.value : this.id,
      pregnancyId: data.pregnancyId.present
          ? data.pregnancyId.value
          : this.pregnancyId,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contraction(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pregnancyId, startTime, endTime);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contraction &&
          other.id == this.id &&
          other.pregnancyId == this.pregnancyId &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime);
}

class ContractionsCompanion extends UpdateCompanion<Contraction> {
  final Value<int> id;
  final Value<int> pregnancyId;
  final Value<DateTime> startTime;
  final Value<DateTime> endTime;
  const ContractionsCompanion({
    this.id = const Value.absent(),
    this.pregnancyId = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
  });
  ContractionsCompanion.insert({
    this.id = const Value.absent(),
    required int pregnancyId,
    required DateTime startTime,
    required DateTime endTime,
  }) : pregnancyId = Value(pregnancyId),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<Contraction> custom({
    Expression<int>? id,
    Expression<int>? pregnancyId,
    Expression<DateTime>? startTime,
    Expression<DateTime>? endTime,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pregnancyId != null) 'pregnancy_id': pregnancyId,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
    });
  }

  ContractionsCompanion copyWith({
    Value<int>? id,
    Value<int>? pregnancyId,
    Value<DateTime>? startTime,
    Value<DateTime>? endTime,
  }) {
    return ContractionsCompanion(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pregnancyId.present) {
      map['pregnancy_id'] = Variable<int>(pregnancyId.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<DateTime>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<DateTime>(endTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractionsCompanion(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime')
          ..write(')'))
        .toString();
  }
}

class $AppointmentsTable extends Appointments
    with TableInfo<$AppointmentsTable, Appointment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppointmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pregnancyIdMeta = const VerificationMeta(
    'pregnancyId',
  );
  @override
  late final GeneratedColumn<int> pregnancyId = GeneratedColumn<int>(
    'pregnancy_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledForMeta = const VerificationMeta(
    'scheduledFor',
  );
  @override
  late final GeneratedColumn<DateTime> scheduledFor = GeneratedColumn<DateTime>(
    'scheduled_for',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
    id,
    pregnancyId,
    scheduledFor,
    title,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'appointments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Appointment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pregnancy_id')) {
      context.handle(
        _pregnancyIdMeta,
        pregnancyId.isAcceptableOrUnknown(
          data['pregnancy_id']!,
          _pregnancyIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pregnancyIdMeta);
    }
    if (data.containsKey('scheduled_for')) {
      context.handle(
        _scheduledForMeta,
        scheduledFor.isAcceptableOrUnknown(
          data['scheduled_for']!,
          _scheduledForMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledForMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Appointment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Appointment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      pregnancyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pregnancy_id'],
      )!,
      scheduledFor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}scheduled_for'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $AppointmentsTable createAlias(String alias) {
    return $AppointmentsTable(attachedDatabase, alias);
  }
}

class Appointment extends DataClass implements Insertable<Appointment> {
  final int id;
  final int pregnancyId;
  final DateTime scheduledFor;
  final String title;
  final String? notes;
  const Appointment({
    required this.id,
    required this.pregnancyId,
    required this.scheduledFor,
    required this.title,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pregnancy_id'] = Variable<int>(pregnancyId);
    map['scheduled_for'] = Variable<DateTime>(scheduledFor);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AppointmentsCompanion toCompanion(bool nullToAbsent) {
    return AppointmentsCompanion(
      id: Value(id),
      pregnancyId: Value(pregnancyId),
      scheduledFor: Value(scheduledFor),
      title: Value(title),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Appointment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Appointment(
      id: serializer.fromJson<int>(json['id']),
      pregnancyId: serializer.fromJson<int>(json['pregnancyId']),
      scheduledFor: serializer.fromJson<DateTime>(json['scheduledFor']),
      title: serializer.fromJson<String>(json['title']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pregnancyId': serializer.toJson<int>(pregnancyId),
      'scheduledFor': serializer.toJson<DateTime>(scheduledFor),
      'title': serializer.toJson<String>(title),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Appointment copyWith({
    int? id,
    int? pregnancyId,
    DateTime? scheduledFor,
    String? title,
    Value<String?> notes = const Value.absent(),
  }) => Appointment(
    id: id ?? this.id,
    pregnancyId: pregnancyId ?? this.pregnancyId,
    scheduledFor: scheduledFor ?? this.scheduledFor,
    title: title ?? this.title,
    notes: notes.present ? notes.value : this.notes,
  );
  Appointment copyWithCompanion(AppointmentsCompanion data) {
    return Appointment(
      id: data.id.present ? data.id.value : this.id,
      pregnancyId: data.pregnancyId.present
          ? data.pregnancyId.value
          : this.pregnancyId,
      scheduledFor: data.scheduledFor.present
          ? data.scheduledFor.value
          : this.scheduledFor,
      title: data.title.present ? data.title.value : this.title,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Appointment(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('title: $title, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pregnancyId, scheduledFor, title, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Appointment &&
          other.id == this.id &&
          other.pregnancyId == this.pregnancyId &&
          other.scheduledFor == this.scheduledFor &&
          other.title == this.title &&
          other.notes == this.notes);
}

class AppointmentsCompanion extends UpdateCompanion<Appointment> {
  final Value<int> id;
  final Value<int> pregnancyId;
  final Value<DateTime> scheduledFor;
  final Value<String> title;
  final Value<String?> notes;
  const AppointmentsCompanion({
    this.id = const Value.absent(),
    this.pregnancyId = const Value.absent(),
    this.scheduledFor = const Value.absent(),
    this.title = const Value.absent(),
    this.notes = const Value.absent(),
  });
  AppointmentsCompanion.insert({
    this.id = const Value.absent(),
    required int pregnancyId,
    required DateTime scheduledFor,
    required String title,
    this.notes = const Value.absent(),
  }) : pregnancyId = Value(pregnancyId),
       scheduledFor = Value(scheduledFor),
       title = Value(title);
  static Insertable<Appointment> custom({
    Expression<int>? id,
    Expression<int>? pregnancyId,
    Expression<DateTime>? scheduledFor,
    Expression<String>? title,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pregnancyId != null) 'pregnancy_id': pregnancyId,
      if (scheduledFor != null) 'scheduled_for': scheduledFor,
      if (title != null) 'title': title,
      if (notes != null) 'notes': notes,
    });
  }

  AppointmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? pregnancyId,
    Value<DateTime>? scheduledFor,
    Value<String>? title,
    Value<String?>? notes,
  }) {
    return AppointmentsCompanion(
      id: id ?? this.id,
      pregnancyId: pregnancyId ?? this.pregnancyId,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      title: title ?? this.title,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pregnancyId.present) {
      map['pregnancy_id'] = Variable<int>(pregnancyId.value);
    }
    if (scheduledFor.present) {
      map['scheduled_for'] = Variable<DateTime>(scheduledFor.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppointmentsCompanion(')
          ..write('id: $id, ')
          ..write('pregnancyId: $pregnancyId, ')
          ..write('scheduledFor: $scheduledFor, ')
          ..write('title: $title, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DailyLogsTable dailyLogs = $DailyLogsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $PregnanciesTable pregnancies = $PregnanciesTable(this);
  late final $KickSessionsTable kickSessions = $KickSessionsTable(this);
  late final $ContractionsTable contractions = $ContractionsTable(this);
  late final $AppointmentsTable appointments = $AppointmentsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    dailyLogs,
    appSettings,
    pregnancies,
    kickSessions,
    contractions,
    appointments,
  ];
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
typedef $$PregnanciesTableCreateCompanionBuilder =
    PregnanciesCompanion Function({
      Value<int> id,
      required DateTime lmpDate,
      Value<int> cycleLengthDays,
      Value<DateTime?> ultrasoundDate,
      Value<int?> ultrasoundGestationalAgeDays,
      Value<DateTime?> eddOverride,
      Value<int> outcome,
      Value<DateTime?> outcomeDate,
      Value<String?> notes,
    });
typedef $$PregnanciesTableUpdateCompanionBuilder =
    PregnanciesCompanion Function({
      Value<int> id,
      Value<DateTime> lmpDate,
      Value<int> cycleLengthDays,
      Value<DateTime?> ultrasoundDate,
      Value<int?> ultrasoundGestationalAgeDays,
      Value<DateTime?> eddOverride,
      Value<int> outcome,
      Value<DateTime?> outcomeDate,
      Value<String?> notes,
    });

class $$PregnanciesTableFilterComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableFilterComposer({
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

  ColumnFilters<DateTime> get lmpDate => $composableBuilder(
    column: $table.lmpDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cycleLengthDays => $composableBuilder(
    column: $table.cycleLengthDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultrasoundDate => $composableBuilder(
    column: $table.ultrasoundDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ultrasoundGestationalAgeDays => $composableBuilder(
    column: $table.ultrasoundGestationalAgeDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eddOverride => $composableBuilder(
    column: $table.eddOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get outcomeDate => $composableBuilder(
    column: $table.outcomeDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PregnanciesTableOrderingComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get lmpDate => $composableBuilder(
    column: $table.lmpDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cycleLengthDays => $composableBuilder(
    column: $table.cycleLengthDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultrasoundDate => $composableBuilder(
    column: $table.ultrasoundDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ultrasoundGestationalAgeDays => $composableBuilder(
    column: $table.ultrasoundGestationalAgeDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eddOverride => $composableBuilder(
    column: $table.eddOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get outcomeDate => $composableBuilder(
    column: $table.outcomeDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PregnanciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PregnanciesTable> {
  $$PregnanciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get lmpDate =>
      $composableBuilder(column: $table.lmpDate, builder: (column) => column);

  GeneratedColumn<int> get cycleLengthDays => $composableBuilder(
    column: $table.cycleLengthDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ultrasoundDate => $composableBuilder(
    column: $table.ultrasoundDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ultrasoundGestationalAgeDays => $composableBuilder(
    column: $table.ultrasoundGestationalAgeDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get eddOverride => $composableBuilder(
    column: $table.eddOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<DateTime> get outcomeDate => $composableBuilder(
    column: $table.outcomeDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PregnanciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PregnanciesTable,
          Pregnancy,
          $$PregnanciesTableFilterComposer,
          $$PregnanciesTableOrderingComposer,
          $$PregnanciesTableAnnotationComposer,
          $$PregnanciesTableCreateCompanionBuilder,
          $$PregnanciesTableUpdateCompanionBuilder,
          (
            Pregnancy,
            BaseReferences<_$AppDatabase, $PregnanciesTable, Pregnancy>,
          ),
          Pregnancy,
          PrefetchHooks Function()
        > {
  $$PregnanciesTableTableManager(_$AppDatabase db, $PregnanciesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PregnanciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PregnanciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PregnanciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> lmpDate = const Value.absent(),
                Value<int> cycleLengthDays = const Value.absent(),
                Value<DateTime?> ultrasoundDate = const Value.absent(),
                Value<int?> ultrasoundGestationalAgeDays = const Value.absent(),
                Value<DateTime?> eddOverride = const Value.absent(),
                Value<int> outcome = const Value.absent(),
                Value<DateTime?> outcomeDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PregnanciesCompanion(
                id: id,
                lmpDate: lmpDate,
                cycleLengthDays: cycleLengthDays,
                ultrasoundDate: ultrasoundDate,
                ultrasoundGestationalAgeDays: ultrasoundGestationalAgeDays,
                eddOverride: eddOverride,
                outcome: outcome,
                outcomeDate: outcomeDate,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime lmpDate,
                Value<int> cycleLengthDays = const Value.absent(),
                Value<DateTime?> ultrasoundDate = const Value.absent(),
                Value<int?> ultrasoundGestationalAgeDays = const Value.absent(),
                Value<DateTime?> eddOverride = const Value.absent(),
                Value<int> outcome = const Value.absent(),
                Value<DateTime?> outcomeDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => PregnanciesCompanion.insert(
                id: id,
                lmpDate: lmpDate,
                cycleLengthDays: cycleLengthDays,
                ultrasoundDate: ultrasoundDate,
                ultrasoundGestationalAgeDays: ultrasoundGestationalAgeDays,
                eddOverride: eddOverride,
                outcome: outcome,
                outcomeDate: outcomeDate,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PregnanciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PregnanciesTable,
      Pregnancy,
      $$PregnanciesTableFilterComposer,
      $$PregnanciesTableOrderingComposer,
      $$PregnanciesTableAnnotationComposer,
      $$PregnanciesTableCreateCompanionBuilder,
      $$PregnanciesTableUpdateCompanionBuilder,
      (Pregnancy, BaseReferences<_$AppDatabase, $PregnanciesTable, Pregnancy>),
      Pregnancy,
      PrefetchHooks Function()
    >;
typedef $$KickSessionsTableCreateCompanionBuilder =
    KickSessionsCompanion Function({
      Value<int> id,
      required int pregnancyId,
      required DateTime startTime,
      Value<DateTime?> endTime,
      Value<int> kickCount,
    });
typedef $$KickSessionsTableUpdateCompanionBuilder =
    KickSessionsCompanion Function({
      Value<int> id,
      Value<int> pregnancyId,
      Value<DateTime> startTime,
      Value<DateTime?> endTime,
      Value<int> kickCount,
    });

class $$KickSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $KickSessionsTable> {
  $$KickSessionsTableFilterComposer({
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

  ColumnFilters<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kickCount => $composableBuilder(
    column: $table.kickCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KickSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $KickSessionsTable> {
  $$KickSessionsTableOrderingComposer({
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

  ColumnOrderings<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kickCount => $composableBuilder(
    column: $table.kickCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KickSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $KickSessionsTable> {
  $$KickSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<int> get kickCount =>
      $composableBuilder(column: $table.kickCount, builder: (column) => column);
}

class $$KickSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $KickSessionsTable,
          KickSession,
          $$KickSessionsTableFilterComposer,
          $$KickSessionsTableOrderingComposer,
          $$KickSessionsTableAnnotationComposer,
          $$KickSessionsTableCreateCompanionBuilder,
          $$KickSessionsTableUpdateCompanionBuilder,
          (
            KickSession,
            BaseReferences<_$AppDatabase, $KickSessionsTable, KickSession>,
          ),
          KickSession,
          PrefetchHooks Function()
        > {
  $$KickSessionsTableTableManager(_$AppDatabase db, $KickSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KickSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KickSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KickSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pregnancyId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> kickCount = const Value.absent(),
              }) => KickSessionsCompanion(
                id: id,
                pregnancyId: pregnancyId,
                startTime: startTime,
                endTime: endTime,
                kickCount: kickCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pregnancyId,
                required DateTime startTime,
                Value<DateTime?> endTime = const Value.absent(),
                Value<int> kickCount = const Value.absent(),
              }) => KickSessionsCompanion.insert(
                id: id,
                pregnancyId: pregnancyId,
                startTime: startTime,
                endTime: endTime,
                kickCount: kickCount,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KickSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $KickSessionsTable,
      KickSession,
      $$KickSessionsTableFilterComposer,
      $$KickSessionsTableOrderingComposer,
      $$KickSessionsTableAnnotationComposer,
      $$KickSessionsTableCreateCompanionBuilder,
      $$KickSessionsTableUpdateCompanionBuilder,
      (
        KickSession,
        BaseReferences<_$AppDatabase, $KickSessionsTable, KickSession>,
      ),
      KickSession,
      PrefetchHooks Function()
    >;
typedef $$ContractionsTableCreateCompanionBuilder =
    ContractionsCompanion Function({
      Value<int> id,
      required int pregnancyId,
      required DateTime startTime,
      required DateTime endTime,
    });
typedef $$ContractionsTableUpdateCompanionBuilder =
    ContractionsCompanion Function({
      Value<int> id,
      Value<int> pregnancyId,
      Value<DateTime> startTime,
      Value<DateTime> endTime,
    });

class $$ContractionsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractionsTable> {
  $$ContractionsTableFilterComposer({
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

  ColumnFilters<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ContractionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractionsTable> {
  $$ContractionsTableOrderingComposer({
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

  ColumnOrderings<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ContractionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractionsTable> {
  $$ContractionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<DateTime> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);
}

class $$ContractionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractionsTable,
          Contraction,
          $$ContractionsTableFilterComposer,
          $$ContractionsTableOrderingComposer,
          $$ContractionsTableAnnotationComposer,
          $$ContractionsTableCreateCompanionBuilder,
          $$ContractionsTableUpdateCompanionBuilder,
          (
            Contraction,
            BaseReferences<_$AppDatabase, $ContractionsTable, Contraction>,
          ),
          Contraction,
          PrefetchHooks Function()
        > {
  $$ContractionsTableTableManager(_$AppDatabase db, $ContractionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pregnancyId = const Value.absent(),
                Value<DateTime> startTime = const Value.absent(),
                Value<DateTime> endTime = const Value.absent(),
              }) => ContractionsCompanion(
                id: id,
                pregnancyId: pregnancyId,
                startTime: startTime,
                endTime: endTime,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pregnancyId,
                required DateTime startTime,
                required DateTime endTime,
              }) => ContractionsCompanion.insert(
                id: id,
                pregnancyId: pregnancyId,
                startTime: startTime,
                endTime: endTime,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ContractionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractionsTable,
      Contraction,
      $$ContractionsTableFilterComposer,
      $$ContractionsTableOrderingComposer,
      $$ContractionsTableAnnotationComposer,
      $$ContractionsTableCreateCompanionBuilder,
      $$ContractionsTableUpdateCompanionBuilder,
      (
        Contraction,
        BaseReferences<_$AppDatabase, $ContractionsTable, Contraction>,
      ),
      Contraction,
      PrefetchHooks Function()
    >;
typedef $$AppointmentsTableCreateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      required int pregnancyId,
      required DateTime scheduledFor,
      required String title,
      Value<String?> notes,
    });
typedef $$AppointmentsTableUpdateCompanionBuilder =
    AppointmentsCompanion Function({
      Value<int> id,
      Value<int> pregnancyId,
      Value<DateTime> scheduledFor,
      Value<String> title,
      Value<String?> notes,
    });

class $$AppointmentsTableFilterComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableFilterComposer({
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

  ColumnFilters<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppointmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableOrderingComposer({
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

  ColumnOrderings<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppointmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppointmentsTable> {
  $$AppointmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get pregnancyId => $composableBuilder(
    column: $table.pregnancyId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get scheduledFor => $composableBuilder(
    column: $table.scheduledFor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AppointmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppointmentsTable,
          Appointment,
          $$AppointmentsTableFilterComposer,
          $$AppointmentsTableOrderingComposer,
          $$AppointmentsTableAnnotationComposer,
          $$AppointmentsTableCreateCompanionBuilder,
          $$AppointmentsTableUpdateCompanionBuilder,
          (
            Appointment,
            BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>,
          ),
          Appointment,
          PrefetchHooks Function()
        > {
  $$AppointmentsTableTableManager(_$AppDatabase db, $AppointmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppointmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppointmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppointmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> pregnancyId = const Value.absent(),
                Value<DateTime> scheduledFor = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => AppointmentsCompanion(
                id: id,
                pregnancyId: pregnancyId,
                scheduledFor: scheduledFor,
                title: title,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int pregnancyId,
                required DateTime scheduledFor,
                required String title,
                Value<String?> notes = const Value.absent(),
              }) => AppointmentsCompanion.insert(
                id: id,
                pregnancyId: pregnancyId,
                scheduledFor: scheduledFor,
                title: title,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppointmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppointmentsTable,
      Appointment,
      $$AppointmentsTableFilterComposer,
      $$AppointmentsTableOrderingComposer,
      $$AppointmentsTableAnnotationComposer,
      $$AppointmentsTableCreateCompanionBuilder,
      $$AppointmentsTableUpdateCompanionBuilder,
      (
        Appointment,
        BaseReferences<_$AppDatabase, $AppointmentsTable, Appointment>,
      ),
      Appointment,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DailyLogsTableTableManager get dailyLogs =>
      $$DailyLogsTableTableManager(_db, _db.dailyLogs);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$PregnanciesTableTableManager get pregnancies =>
      $$PregnanciesTableTableManager(_db, _db.pregnancies);
  $$KickSessionsTableTableManager get kickSessions =>
      $$KickSessionsTableTableManager(_db, _db.kickSessions);
  $$ContractionsTableTableManager get contractions =>
      $$ContractionsTableTableManager(_db, _db.contractions);
  $$AppointmentsTableTableManager get appointments =>
      $$AppointmentsTableTableManager(_db, _db.appointments);
}
