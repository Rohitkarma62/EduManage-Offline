// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InstitutesTable extends Institutes
    with TableInfo<$InstitutesTable, Institute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstitutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _academicYearMeta =
      const VerificationMeta('academicYear');
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
      'academic_year', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 4, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 7, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 3, maxTextLength: 3),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('INR'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, academicYear, phone, currencyCode, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'institutes';
  @override
  VerificationContext validateIntegrity(Insertable<Institute> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('academic_year')) {
      context.handle(
          _academicYearMeta,
          academicYear.isAcceptableOrUnknown(
              data['academic_year']!, _academicYearMeta));
    } else if (isInserting) {
      context.missing(_academicYearMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Institute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Institute(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      academicYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}academic_year'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $InstitutesTable createAlias(String alias) {
    return $InstitutesTable(attachedDatabase, alias);
  }
}

class Institute extends DataClass implements Insertable<Institute> {
  final int id;
  final String name;
  final String academicYear;
  final String? phone;
  final String currencyCode;
  final DateTime createdAt;
  const Institute(
      {required this.id,
      required this.name,
      required this.academicYear,
      this.phone,
      required this.currencyCode,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['academic_year'] = Variable<String>(academicYear);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InstitutesCompanion toCompanion(bool nullToAbsent) {
    return InstitutesCompanion(
      id: Value(id),
      name: Value(name),
      academicYear: Value(academicYear),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      currencyCode: Value(currencyCode),
      createdAt: Value(createdAt),
    );
  }

  factory Institute.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Institute(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      academicYear: serializer.fromJson<String>(json['academicYear']),
      phone: serializer.fromJson<String?>(json['phone']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'academicYear': serializer.toJson<String>(academicYear),
      'phone': serializer.toJson<String?>(phone),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Institute copyWith(
          {int? id,
          String? name,
          String? academicYear,
          Value<String?> phone = const Value.absent(),
          String? currencyCode,
          DateTime? createdAt}) =>
      Institute(
        id: id ?? this.id,
        name: name ?? this.name,
        academicYear: academicYear ?? this.academicYear,
        phone: phone.present ? phone.value : this.phone,
        currencyCode: currencyCode ?? this.currencyCode,
        createdAt: createdAt ?? this.createdAt,
      );
  Institute copyWithCompanion(InstitutesCompanion data) {
    return Institute(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      academicYear: data.academicYear.present
          ? data.academicYear.value
          : this.academicYear,
      phone: data.phone.present ? data.phone.value : this.phone,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Institute(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('academicYear: $academicYear, ')
          ..write('phone: $phone, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, academicYear, phone, currencyCode, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Institute &&
          other.id == this.id &&
          other.name == this.name &&
          other.academicYear == this.academicYear &&
          other.phone == this.phone &&
          other.currencyCode == this.currencyCode &&
          other.createdAt == this.createdAt);
}

class InstitutesCompanion extends UpdateCompanion<Institute> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> academicYear;
  final Value<String?> phone;
  final Value<String> currencyCode;
  final Value<DateTime> createdAt;
  const InstitutesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.phone = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InstitutesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String academicYear,
    this.phone = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        academicYear = Value(academicYear);
  static Insertable<Institute> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? academicYear,
    Expression<String>? phone,
    Expression<String>? currencyCode,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (academicYear != null) 'academic_year': academicYear,
      if (phone != null) 'phone': phone,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InstitutesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? academicYear,
      Value<String?>? phone,
      Value<String>? currencyCode,
      Value<DateTime>? createdAt}) {
    return InstitutesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      phone: phone ?? this.phone,
      currencyCode: currencyCode ?? this.currencyCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstitutesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('academicYear: $academicYear, ')
          ..write('phone: $phone, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstitutesTable institutes = $InstitutesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [institutes];
}

typedef $$InstitutesTableCreateCompanionBuilder = InstitutesCompanion Function({
  Value<int> id,
  required String name,
  required String academicYear,
  Value<String?> phone,
  Value<String> currencyCode,
  Value<DateTime> createdAt,
});
typedef $$InstitutesTableUpdateCompanionBuilder = InstitutesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> academicYear,
  Value<String?> phone,
  Value<String> currencyCode,
  Value<DateTime> createdAt,
});

class $$InstitutesTableFilterComposer
    extends Composer<_$AppDatabase, $InstitutesTable> {
  $$InstitutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get academicYear => $composableBuilder(
      column: $table.academicYear, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$InstitutesTableOrderingComposer
    extends Composer<_$AppDatabase, $InstitutesTable> {
  $$InstitutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get academicYear => $composableBuilder(
      column: $table.academicYear,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$InstitutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstitutesTable> {
  $$InstitutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get academicYear => $composableBuilder(
      column: $table.academicYear, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$InstitutesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InstitutesTable,
    Institute,
    $$InstitutesTableFilterComposer,
    $$InstitutesTableOrderingComposer,
    $$InstitutesTableAnnotationComposer,
    $$InstitutesTableCreateCompanionBuilder,
    $$InstitutesTableUpdateCompanionBuilder,
    (Institute, BaseReferences<_$AppDatabase, $InstitutesTable, Institute>),
    Institute,
    PrefetchHooks Function()> {
  $$InstitutesTableTableManager(_$AppDatabase db, $InstitutesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstitutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstitutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstitutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> academicYear = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InstitutesCompanion(
            id: id,
            name: name,
            academicYear: academicYear,
            phone: phone,
            currencyCode: currencyCode,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String academicYear,
            Value<String?> phone = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              InstitutesCompanion.insert(
            id: id,
            name: name,
            academicYear: academicYear,
            phone: phone,
            currencyCode: currencyCode,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InstitutesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InstitutesTable,
    Institute,
    $$InstitutesTableFilterComposer,
    $$InstitutesTableOrderingComposer,
    $$InstitutesTableAnnotationComposer,
    $$InstitutesTableCreateCompanionBuilder,
    $$InstitutesTableUpdateCompanionBuilder,
    (Institute, BaseReferences<_$AppDatabase, $InstitutesTable, Institute>),
    Institute,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstitutesTableTableManager get institutes =>
      $$InstitutesTableTableManager(_db, _db.institutes);
}
