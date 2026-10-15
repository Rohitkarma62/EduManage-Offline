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

class $ClassesTable extends Classes with TableInfo<$ClassesTable, ClassBatch> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
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
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
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
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 240),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, academicYear, description, isActive, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(Insertable<ClassBatch> instance,
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
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {name, academicYear},
      ];
  @override
  ClassBatch map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassBatch(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      academicYear: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}academic_year'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class ClassBatch extends DataClass implements Insertable<ClassBatch> {
  final int id;
  final String name;
  final String academicYear;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ClassBatch(
      {required this.id,
      required this.name,
      required this.academicYear,
      this.description,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['academic_year'] = Variable<String>(academicYear);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      name: Value(name),
      academicYear: Value(academicYear),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ClassBatch.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassBatch(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      academicYear: serializer.fromJson<String>(json['academicYear']),
      description: serializer.fromJson<String?>(json['description']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'academicYear': serializer.toJson<String>(academicYear),
      'description': serializer.toJson<String?>(description),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ClassBatch copyWith(
          {int? id,
          String? name,
          String? academicYear,
          Value<String?> description = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ClassBatch(
        id: id ?? this.id,
        name: name ?? this.name,
        academicYear: academicYear ?? this.academicYear,
        description: description.present ? description.value : this.description,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ClassBatch copyWithCompanion(ClassesCompanion data) {
    return ClassBatch(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      academicYear: data.academicYear.present
          ? data.academicYear.value
          : this.academicYear,
      description:
          data.description.present ? data.description.value : this.description,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassBatch(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('academicYear: $academicYear, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, academicYear, description, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassBatch &&
          other.id == this.id &&
          other.name == this.name &&
          other.academicYear == this.academicYear &&
          other.description == this.description &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ClassesCompanion extends UpdateCompanion<ClassBatch> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> academicYear;
  final Value<String?> description;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ClassesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String academicYear,
    this.description = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        academicYear = Value(academicYear);
  static Insertable<ClassBatch> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? academicYear,
    Expression<String>? description,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (academicYear != null) 'academic_year': academicYear,
      if (description != null) 'description': description,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ClassesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? academicYear,
      Value<String?>? description,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ClassesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      academicYear: academicYear ?? this.academicYear,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('academicYear: $academicYear, ')
          ..write('description: $description, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _admissionNumberMeta =
      const VerificationMeta('admissionNumber');
  @override
  late final GeneratedColumn<String> admissionNumber = GeneratedColumn<String>(
      'admission_number', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 40),
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _fullNameMeta =
      const VerificationMeta('fullName');
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
      'full_name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
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
  static const VerificationMeta _guardianNameMeta =
      const VerificationMeta('guardianName');
  @override
  late final GeneratedColumn<String> guardianName = GeneratedColumn<String>(
      'guardian_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
      'class_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        admissionNumber,
        fullName,
        phone,
        guardianName,
        classId,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(Insertable<Student> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('admission_number')) {
      context.handle(
          _admissionNumberMeta,
          admissionNumber.isAcceptableOrUnknown(
              data['admission_number']!, _admissionNumberMeta));
    } else if (isInserting) {
      context.missing(_admissionNumberMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(_fullNameMeta,
          fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta));
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('guardian_name')) {
      context.handle(
          _guardianNameMeta,
          guardianName.isAcceptableOrUnknown(
              data['guardian_name']!, _guardianNameMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      admissionNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}admission_number'])!,
      fullName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}full_name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      guardianName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}guardian_name']),
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}class_id']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;
  final String admissionNumber;
  final String fullName;
  final String? phone;
  final String? guardianName;
  final int? classId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Student(
      {required this.id,
      required this.admissionNumber,
      required this.fullName,
      this.phone,
      this.guardianName,
      this.classId,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['admission_number'] = Variable<String>(admissionNumber);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || guardianName != null) {
      map['guardian_name'] = Variable<String>(guardianName);
    }
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<int>(classId);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      admissionNumber: Value(admissionNumber),
      fullName: Value(fullName),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      guardianName: guardianName == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianName),
      classId: classId == null && nullToAbsent
          ? const Value.absent()
          : Value(classId),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Student.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      admissionNumber: serializer.fromJson<String>(json['admissionNumber']),
      fullName: serializer.fromJson<String>(json['fullName']),
      phone: serializer.fromJson<String?>(json['phone']),
      guardianName: serializer.fromJson<String?>(json['guardianName']),
      classId: serializer.fromJson<int?>(json['classId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'admissionNumber': serializer.toJson<String>(admissionNumber),
      'fullName': serializer.toJson<String>(fullName),
      'phone': serializer.toJson<String?>(phone),
      'guardianName': serializer.toJson<String?>(guardianName),
      'classId': serializer.toJson<int?>(classId),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Student copyWith(
          {int? id,
          String? admissionNumber,
          String? fullName,
          Value<String?> phone = const Value.absent(),
          Value<String?> guardianName = const Value.absent(),
          Value<int?> classId = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Student(
        id: id ?? this.id,
        admissionNumber: admissionNumber ?? this.admissionNumber,
        fullName: fullName ?? this.fullName,
        phone: phone.present ? phone.value : this.phone,
        guardianName:
            guardianName.present ? guardianName.value : this.guardianName,
        classId: classId.present ? classId.value : this.classId,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      admissionNumber: data.admissionNumber.present
          ? data.admissionNumber.value
          : this.admissionNumber,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      phone: data.phone.present ? data.phone.value : this.phone,
      guardianName: data.guardianName.present
          ? data.guardianName.value
          : this.guardianName,
      classId: data.classId.present ? data.classId.value : this.classId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('admissionNumber: $admissionNumber, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('guardianName: $guardianName, ')
          ..write('classId: $classId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, admissionNumber, fullName, phone,
      guardianName, classId, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.admissionNumber == this.admissionNumber &&
          other.fullName == this.fullName &&
          other.phone == this.phone &&
          other.guardianName == this.guardianName &&
          other.classId == this.classId &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<String> admissionNumber;
  final Value<String> fullName;
  final Value<String?> phone;
  final Value<String?> guardianName;
  final Value<int?> classId;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.admissionNumber = const Value.absent(),
    this.fullName = const Value.absent(),
    this.phone = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.classId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required String admissionNumber,
    required String fullName,
    this.phone = const Value.absent(),
    this.guardianName = const Value.absent(),
    this.classId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : admissionNumber = Value(admissionNumber),
        fullName = Value(fullName);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<String>? admissionNumber,
    Expression<String>? fullName,
    Expression<String>? phone,
    Expression<String>? guardianName,
    Expression<int>? classId,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (admissionNumber != null) 'admission_number': admissionNumber,
      if (fullName != null) 'full_name': fullName,
      if (phone != null) 'phone': phone,
      if (guardianName != null) 'guardian_name': guardianName,
      if (classId != null) 'class_id': classId,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StudentsCompanion copyWith(
      {Value<int>? id,
      Value<String>? admissionNumber,
      Value<String>? fullName,
      Value<String?>? phone,
      Value<String?>? guardianName,
      Value<int?>? classId,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return StudentsCompanion(
      id: id ?? this.id,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      guardianName: guardianName ?? this.guardianName,
      classId: classId ?? this.classId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (admissionNumber.present) {
      map['admission_number'] = Variable<String>(admissionNumber.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (guardianName.present) {
      map['guardian_name'] = Variable<String>(guardianName.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('admissionNumber: $admissionNumber, ')
          ..write('fullName: $fullName, ')
          ..write('phone: $phone, ')
          ..write('guardianName: $guardianName, ')
          ..write('classId: $classId, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BatchesTable extends Batches
    with TableInfo<$BatchesTable, ClassBatchSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
      'class_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _subjectMeta =
      const VerificationMeta('subject');
  @override
  late final GeneratedColumn<String> subject = GeneratedColumn<String>(
      'subject', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 80),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _timingMeta = const VerificationMeta('timing');
  @override
  late final GeneratedColumn<String> timing = GeneratedColumn<String>(
      'timing', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 100),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _teacherNameMeta =
      const VerificationMeta('teacherName');
  @override
  late final GeneratedColumn<String> teacherName = GeneratedColumn<String>(
      'teacher_name', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _monthlyFeePaiseMeta =
      const VerificationMeta('monthlyFeePaise');
  @override
  late final GeneratedColumn<int> monthlyFeePaise = GeneratedColumn<int>(
      'monthly_fee_paise', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        classId,
        name,
        subject,
        timing,
        teacherName,
        monthlyFeePaise,
        isActive,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'batches';
  @override
  VerificationContext validateIntegrity(Insertable<ClassBatchSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('subject')) {
      context.handle(_subjectMeta,
          subject.isAcceptableOrUnknown(data['subject']!, _subjectMeta));
    }
    if (data.containsKey('timing')) {
      context.handle(_timingMeta,
          timing.isAcceptableOrUnknown(data['timing']!, _timingMeta));
    }
    if (data.containsKey('teacher_name')) {
      context.handle(
          _teacherNameMeta,
          teacherName.isAcceptableOrUnknown(
              data['teacher_name']!, _teacherNameMeta));
    }
    if (data.containsKey('monthly_fee_paise')) {
      context.handle(
          _monthlyFeePaiseMeta,
          monthlyFeePaise.isAcceptableOrUnknown(
              data['monthly_fee_paise']!, _monthlyFeePaiseMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {classId, name},
      ];
  @override
  ClassBatchSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassBatchSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}class_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      subject: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject']),
      timing: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timing']),
      teacherName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_name']),
      monthlyFeePaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}monthly_fee_paise']),
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $BatchesTable createAlias(String alias) {
    return $BatchesTable(attachedDatabase, alias);
  }
}

class ClassBatchSession extends DataClass
    implements Insertable<ClassBatchSession> {
  final int id;
  final int classId;
  final String name;
  final String? subject;
  final String? timing;
  final String? teacherName;
  final int? monthlyFeePaise;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ClassBatchSession(
      {required this.id,
      required this.classId,
      required this.name,
      this.subject,
      this.timing,
      this.teacherName,
      this.monthlyFeePaise,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['class_id'] = Variable<int>(classId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || subject != null) {
      map['subject'] = Variable<String>(subject);
    }
    if (!nullToAbsent || timing != null) {
      map['timing'] = Variable<String>(timing);
    }
    if (!nullToAbsent || teacherName != null) {
      map['teacher_name'] = Variable<String>(teacherName);
    }
    if (!nullToAbsent || monthlyFeePaise != null) {
      map['monthly_fee_paise'] = Variable<int>(monthlyFeePaise);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BatchesCompanion toCompanion(bool nullToAbsent) {
    return BatchesCompanion(
      id: Value(id),
      classId: Value(classId),
      name: Value(name),
      subject: subject == null && nullToAbsent
          ? const Value.absent()
          : Value(subject),
      timing:
          timing == null && nullToAbsent ? const Value.absent() : Value(timing),
      teacherName: teacherName == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherName),
      monthlyFeePaise: monthlyFeePaise == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyFeePaise),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ClassBatchSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassBatchSession(
      id: serializer.fromJson<int>(json['id']),
      classId: serializer.fromJson<int>(json['classId']),
      name: serializer.fromJson<String>(json['name']),
      subject: serializer.fromJson<String?>(json['subject']),
      timing: serializer.fromJson<String?>(json['timing']),
      teacherName: serializer.fromJson<String?>(json['teacherName']),
      monthlyFeePaise: serializer.fromJson<int?>(json['monthlyFeePaise']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'classId': serializer.toJson<int>(classId),
      'name': serializer.toJson<String>(name),
      'subject': serializer.toJson<String?>(subject),
      'timing': serializer.toJson<String?>(timing),
      'teacherName': serializer.toJson<String?>(teacherName),
      'monthlyFeePaise': serializer.toJson<int?>(monthlyFeePaise),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ClassBatchSession copyWith(
          {int? id,
          int? classId,
          String? name,
          Value<String?> subject = const Value.absent(),
          Value<String?> timing = const Value.absent(),
          Value<String?> teacherName = const Value.absent(),
          Value<int?> monthlyFeePaise = const Value.absent(),
          bool? isActive,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      ClassBatchSession(
        id: id ?? this.id,
        classId: classId ?? this.classId,
        name: name ?? this.name,
        subject: subject.present ? subject.value : this.subject,
        timing: timing.present ? timing.value : this.timing,
        teacherName: teacherName.present ? teacherName.value : this.teacherName,
        monthlyFeePaise: monthlyFeePaise.present
            ? monthlyFeePaise.value
            : this.monthlyFeePaise,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  ClassBatchSession copyWithCompanion(BatchesCompanion data) {
    return ClassBatchSession(
      id: data.id.present ? data.id.value : this.id,
      classId: data.classId.present ? data.classId.value : this.classId,
      name: data.name.present ? data.name.value : this.name,
      subject: data.subject.present ? data.subject.value : this.subject,
      timing: data.timing.present ? data.timing.value : this.timing,
      teacherName:
          data.teacherName.present ? data.teacherName.value : this.teacherName,
      monthlyFeePaise: data.monthlyFeePaise.present
          ? data.monthlyFeePaise.value
          : this.monthlyFeePaise,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassBatchSession(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('subject: $subject, ')
          ..write('timing: $timing, ')
          ..write('teacherName: $teacherName, ')
          ..write('monthlyFeePaise: $monthlyFeePaise, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, classId, name, subject, timing,
      teacherName, monthlyFeePaise, isActive, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassBatchSession &&
          other.id == this.id &&
          other.classId == this.classId &&
          other.name == this.name &&
          other.subject == this.subject &&
          other.timing == this.timing &&
          other.teacherName == this.teacherName &&
          other.monthlyFeePaise == this.monthlyFeePaise &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BatchesCompanion extends UpdateCompanion<ClassBatchSession> {
  final Value<int> id;
  final Value<int> classId;
  final Value<String> name;
  final Value<String?> subject;
  final Value<String?> timing;
  final Value<String?> teacherName;
  final Value<int?> monthlyFeePaise;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BatchesCompanion({
    this.id = const Value.absent(),
    this.classId = const Value.absent(),
    this.name = const Value.absent(),
    this.subject = const Value.absent(),
    this.timing = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.monthlyFeePaise = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BatchesCompanion.insert({
    this.id = const Value.absent(),
    required int classId,
    required String name,
    this.subject = const Value.absent(),
    this.timing = const Value.absent(),
    this.teacherName = const Value.absent(),
    this.monthlyFeePaise = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : classId = Value(classId),
        name = Value(name);
  static Insertable<ClassBatchSession> custom({
    Expression<int>? id,
    Expression<int>? classId,
    Expression<String>? name,
    Expression<String>? subject,
    Expression<String>? timing,
    Expression<String>? teacherName,
    Expression<int>? monthlyFeePaise,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (classId != null) 'class_id': classId,
      if (name != null) 'name': name,
      if (subject != null) 'subject': subject,
      if (timing != null) 'timing': timing,
      if (teacherName != null) 'teacher_name': teacherName,
      if (monthlyFeePaise != null) 'monthly_fee_paise': monthlyFeePaise,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BatchesCompanion copyWith(
      {Value<int>? id,
      Value<int>? classId,
      Value<String>? name,
      Value<String?>? subject,
      Value<String?>? timing,
      Value<String?>? teacherName,
      Value<int?>? monthlyFeePaise,
      Value<bool>? isActive,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return BatchesCompanion(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      timing: timing ?? this.timing,
      teacherName: teacherName ?? this.teacherName,
      monthlyFeePaise: monthlyFeePaise ?? this.monthlyFeePaise,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (subject.present) {
      map['subject'] = Variable<String>(subject.value);
    }
    if (timing.present) {
      map['timing'] = Variable<String>(timing.value);
    }
    if (teacherName.present) {
      map['teacher_name'] = Variable<String>(teacherName.value);
    }
    if (monthlyFeePaise.present) {
      map['monthly_fee_paise'] = Variable<int>(monthlyFeePaise.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BatchesCompanion(')
          ..write('id: $id, ')
          ..write('classId: $classId, ')
          ..write('name: $name, ')
          ..write('subject: $subject, ')
          ..write('timing: $timing, ')
          ..write('teacherName: $teacherName, ')
          ..write('monthlyFeePaise: $monthlyFeePaise, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $StudentAssignmentsTable extends StudentAssignments
    with TableInfo<$StudentAssignmentsTable, StudentAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _classIdMeta =
      const VerificationMeta('classId');
  @override
  late final GeneratedColumn<int> classId = GeneratedColumn<int>(
      'class_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _batchIdMeta =
      const VerificationMeta('batchId');
  @override
  late final GeneratedColumn<int> batchId = GeneratedColumn<int>(
      'batch_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _effectiveFromMeta =
      const VerificationMeta('effectiveFrom');
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>('effective_from', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _effectiveToMeta =
      const VerificationMeta('effectiveTo');
  @override
  late final GeneratedColumn<DateTime> effectiveTo = GeneratedColumn<DateTime>(
      'effective_to', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _transferReasonMeta =
      const VerificationMeta('transferReason');
  @override
  late final GeneratedColumn<String> transferReason = GeneratedColumn<String>(
      'transfer_reason', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 240),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _endReasonMeta =
      const VerificationMeta('endReason');
  @override
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
      'end_reason', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 240),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        classId,
        batchId,
        effectiveFrom,
        effectiveTo,
        transferReason,
        endReason,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_assignments';
  @override
  VerificationContext validateIntegrity(Insertable<StudentAssignment> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(_classIdMeta,
          classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta));
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('batch_id')) {
      context.handle(_batchIdMeta,
          batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta));
    }
    if (data.containsKey('effective_from')) {
      context.handle(
          _effectiveFromMeta,
          effectiveFrom.isAcceptableOrUnknown(
              data['effective_from']!, _effectiveFromMeta));
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('effective_to')) {
      context.handle(
          _effectiveToMeta,
          effectiveTo.isAcceptableOrUnknown(
              data['effective_to']!, _effectiveToMeta));
    }
    if (data.containsKey('transfer_reason')) {
      context.handle(
          _transferReasonMeta,
          transferReason.isAcceptableOrUnknown(
              data['transfer_reason']!, _transferReasonMeta));
    }
    if (data.containsKey('end_reason')) {
      context.handle(_endReasonMeta,
          endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta));
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
  StudentAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentAssignment(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      classId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}class_id'])!,
      batchId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}batch_id']),
      effectiveFrom: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}effective_from'])!,
      effectiveTo: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}effective_to']),
      transferReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}transfer_reason']),
      endReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_reason']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $StudentAssignmentsTable createAlias(String alias) {
    return $StudentAssignmentsTable(attachedDatabase, alias);
  }
}

class StudentAssignment extends DataClass
    implements Insertable<StudentAssignment> {
  final int id;
  final int studentId;
  final int classId;
  final int? batchId;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
  final String? transferReason;
  final String? endReason;
  final DateTime createdAt;
  const StudentAssignment(
      {required this.id,
      required this.studentId,
      required this.classId,
      this.batchId,
      required this.effectiveFrom,
      this.effectiveTo,
      this.transferReason,
      this.endReason,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['class_id'] = Variable<int>(classId);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<int>(batchId);
    }
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    if (!nullToAbsent || effectiveTo != null) {
      map['effective_to'] = Variable<DateTime>(effectiveTo);
    }
    if (!nullToAbsent || transferReason != null) {
      map['transfer_reason'] = Variable<String>(transferReason);
    }
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StudentAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return StudentAssignmentsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      classId: Value(classId),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      effectiveFrom: Value(effectiveFrom),
      effectiveTo: effectiveTo == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveTo),
      transferReason: transferReason == null && nullToAbsent
          ? const Value.absent()
          : Value(transferReason),
      endReason: endReason == null && nullToAbsent
          ? const Value.absent()
          : Value(endReason),
      createdAt: Value(createdAt),
    );
  }

  factory StudentAssignment.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentAssignment(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      classId: serializer.fromJson<int>(json['classId']),
      batchId: serializer.fromJson<int?>(json['batchId']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      effectiveTo: serializer.fromJson<DateTime?>(json['effectiveTo']),
      transferReason: serializer.fromJson<String?>(json['transferReason']),
      endReason: serializer.fromJson<String?>(json['endReason']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'classId': serializer.toJson<int>(classId),
      'batchId': serializer.toJson<int?>(batchId),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'effectiveTo': serializer.toJson<DateTime?>(effectiveTo),
      'transferReason': serializer.toJson<String?>(transferReason),
      'endReason': serializer.toJson<String?>(endReason),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StudentAssignment copyWith(
          {int? id,
          int? studentId,
          int? classId,
          Value<int?> batchId = const Value.absent(),
          DateTime? effectiveFrom,
          Value<DateTime?> effectiveTo = const Value.absent(),
          Value<String?> transferReason = const Value.absent(),
          Value<String?> endReason = const Value.absent(),
          DateTime? createdAt}) =>
      StudentAssignment(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        classId: classId ?? this.classId,
        batchId: batchId.present ? batchId.value : this.batchId,
        effectiveFrom: effectiveFrom ?? this.effectiveFrom,
        effectiveTo: effectiveTo.present ? effectiveTo.value : this.effectiveTo,
        transferReason:
            transferReason.present ? transferReason.value : this.transferReason,
        endReason: endReason.present ? endReason.value : this.endReason,
        createdAt: createdAt ?? this.createdAt,
      );
  StudentAssignment copyWithCompanion(StudentAssignmentsCompanion data) {
    return StudentAssignment(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      classId: data.classId.present ? data.classId.value : this.classId,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      effectiveTo:
          data.effectiveTo.present ? data.effectiveTo.value : this.effectiveTo,
      transferReason: data.transferReason.present
          ? data.transferReason.value
          : this.transferReason,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentAssignment(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('batchId: $batchId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('transferReason: $transferReason, ')
          ..write('endReason: $endReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, classId, batchId,
      effectiveFrom, effectiveTo, transferReason, endReason, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentAssignment &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.classId == this.classId &&
          other.batchId == this.batchId &&
          other.effectiveFrom == this.effectiveFrom &&
          other.effectiveTo == this.effectiveTo &&
          other.transferReason == this.transferReason &&
          other.endReason == this.endReason &&
          other.createdAt == this.createdAt);
}

class StudentAssignmentsCompanion extends UpdateCompanion<StudentAssignment> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> classId;
  final Value<int?> batchId;
  final Value<DateTime> effectiveFrom;
  final Value<DateTime?> effectiveTo;
  final Value<String?> transferReason;
  final Value<String?> endReason;
  final Value<DateTime> createdAt;
  const StudentAssignmentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.classId = const Value.absent(),
    this.batchId = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.effectiveTo = const Value.absent(),
    this.transferReason = const Value.absent(),
    this.endReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StudentAssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int classId,
    this.batchId = const Value.absent(),
    required DateTime effectiveFrom,
    this.effectiveTo = const Value.absent(),
    this.transferReason = const Value.absent(),
    this.endReason = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : studentId = Value(studentId),
        classId = Value(classId),
        effectiveFrom = Value(effectiveFrom);
  static Insertable<StudentAssignment> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? classId,
    Expression<int>? batchId,
    Expression<DateTime>? effectiveFrom,
    Expression<DateTime>? effectiveTo,
    Expression<String>? transferReason,
    Expression<String>? endReason,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (classId != null) 'class_id': classId,
      if (batchId != null) 'batch_id': batchId,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (effectiveTo != null) 'effective_to': effectiveTo,
      if (transferReason != null) 'transfer_reason': transferReason,
      if (endReason != null) 'end_reason': endReason,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StudentAssignmentsCompanion copyWith(
      {Value<int>? id,
      Value<int>? studentId,
      Value<int>? classId,
      Value<int?>? batchId,
      Value<DateTime>? effectiveFrom,
      Value<DateTime?>? effectiveTo,
      Value<String?>? transferReason,
      Value<String?>? endReason,
      Value<DateTime>? createdAt}) {
    return StudentAssignmentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      batchId: batchId ?? this.batchId,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      effectiveTo: effectiveTo ?? this.effectiveTo,
      transferReason: transferReason ?? this.transferReason,
      endReason: endReason ?? this.endReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<int>(classId.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<int>(batchId.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (effectiveTo.present) {
      map['effective_to'] = Variable<DateTime>(effectiveTo.value);
    }
    if (transferReason.present) {
      map['transfer_reason'] = Variable<String>(transferReason.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('classId: $classId, ')
          ..write('batchId: $batchId, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('effectiveTo: $effectiveTo, ')
          ..write('transferReason: $transferReason, ')
          ..write('endReason: $endReason, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $FeeChargesTable extends FeeCharges
    with TableInfo<$FeeChargesTable, FeeCharge> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FeeChargesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _studentIdMeta =
      const VerificationMeta('studentId');
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
      'student_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _assignmentIdMeta =
      const VerificationMeta('assignmentId');
  @override
  late final GeneratedColumn<int> assignmentId = GeneratedColumn<int>(
      'assignment_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 120),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _amountPaiseMeta =
      const VerificationMeta('amountPaise');
  @override
  late final GeneratedColumn<int> amountPaise = GeneratedColumn<int>(
      'amount_paise', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _periodStartMeta =
      const VerificationMeta('periodStart');
  @override
  late final GeneratedColumn<DateTime> periodStart = GeneratedColumn<DateTime>(
      'period_start', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _periodEndMeta =
      const VerificationMeta('periodEnd');
  @override
  late final GeneratedColumn<DateTime> periodEnd = GeneratedColumn<DateTime>(
      'period_end', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        studentId,
        assignmentId,
        title,
        amountPaise,
        periodStart,
        periodEnd,
        dueDate,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fee_charges';
  @override
  VerificationContext validateIntegrity(Insertable<FeeCharge> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(_studentIdMeta,
          studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta));
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('assignment_id')) {
      context.handle(
          _assignmentIdMeta,
          assignmentId.isAcceptableOrUnknown(
              data['assignment_id']!, _assignmentIdMeta));
    } else if (isInserting) {
      context.missing(_assignmentIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount_paise')) {
      context.handle(
          _amountPaiseMeta,
          amountPaise.isAcceptableOrUnknown(
              data['amount_paise']!, _amountPaiseMeta));
    } else if (isInserting) {
      context.missing(_amountPaiseMeta);
    }
    if (data.containsKey('period_start')) {
      context.handle(
          _periodStartMeta,
          periodStart.isAcceptableOrUnknown(
              data['period_start']!, _periodStartMeta));
    } else if (isInserting) {
      context.missing(_periodStartMeta);
    }
    if (data.containsKey('period_end')) {
      context.handle(_periodEndMeta,
          periodEnd.isAcceptableOrUnknown(data['period_end']!, _periodEndMeta));
    } else if (isInserting) {
      context.missing(_periodEndMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
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
  FeeCharge map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeeCharge(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      studentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}student_id'])!,
      assignmentId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}assignment_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amountPaise: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_paise'])!,
      periodStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_start'])!,
      periodEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}period_end'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FeeChargesTable createAlias(String alias) {
    return $FeeChargesTable(attachedDatabase, alias);
  }
}

class FeeCharge extends DataClass implements Insertable<FeeCharge> {
  final int id;
  final int studentId;
  final int assignmentId;
  final String title;
  final int amountPaise;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime dueDate;
  final DateTime createdAt;
  const FeeCharge(
      {required this.id,
      required this.studentId,
      required this.assignmentId,
      required this.title,
      required this.amountPaise,
      required this.periodStart,
      required this.periodEnd,
      required this.dueDate,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['assignment_id'] = Variable<int>(assignmentId);
    map['title'] = Variable<String>(title);
    map['amount_paise'] = Variable<int>(amountPaise);
    map['period_start'] = Variable<DateTime>(periodStart);
    map['period_end'] = Variable<DateTime>(periodEnd);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FeeChargesCompanion toCompanion(bool nullToAbsent) {
    return FeeChargesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      assignmentId: Value(assignmentId),
      title: Value(title),
      amountPaise: Value(amountPaise),
      periodStart: Value(periodStart),
      periodEnd: Value(periodEnd),
      dueDate: Value(dueDate),
      createdAt: Value(createdAt),
    );
  }

  factory FeeCharge.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeeCharge(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      assignmentId: serializer.fromJson<int>(json['assignmentId']),
      title: serializer.fromJson<String>(json['title']),
      amountPaise: serializer.fromJson<int>(json['amountPaise']),
      periodStart: serializer.fromJson<DateTime>(json['periodStart']),
      periodEnd: serializer.fromJson<DateTime>(json['periodEnd']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'assignmentId': serializer.toJson<int>(assignmentId),
      'title': serializer.toJson<String>(title),
      'amountPaise': serializer.toJson<int>(amountPaise),
      'periodStart': serializer.toJson<DateTime>(periodStart),
      'periodEnd': serializer.toJson<DateTime>(periodEnd),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FeeCharge copyWith(
          {int? id,
          int? studentId,
          int? assignmentId,
          String? title,
          int? amountPaise,
          DateTime? periodStart,
          DateTime? periodEnd,
          DateTime? dueDate,
          DateTime? createdAt}) =>
      FeeCharge(
        id: id ?? this.id,
        studentId: studentId ?? this.studentId,
        assignmentId: assignmentId ?? this.assignmentId,
        title: title ?? this.title,
        amountPaise: amountPaise ?? this.amountPaise,
        periodStart: periodStart ?? this.periodStart,
        periodEnd: periodEnd ?? this.periodEnd,
        dueDate: dueDate ?? this.dueDate,
        createdAt: createdAt ?? this.createdAt,
      );
  FeeCharge copyWithCompanion(FeeChargesCompanion data) {
    return FeeCharge(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      assignmentId: data.assignmentId.present
          ? data.assignmentId.value
          : this.assignmentId,
      title: data.title.present ? data.title.value : this.title,
      amountPaise:
          data.amountPaise.present ? data.amountPaise.value : this.amountPaise,
      periodStart:
          data.periodStart.present ? data.periodStart.value : this.periodStart,
      periodEnd: data.periodEnd.present ? data.periodEnd.value : this.periodEnd,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeeCharge(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('title: $title, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, studentId, assignmentId, title,
      amountPaise, periodStart, periodEnd, dueDate, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeeCharge &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.assignmentId == this.assignmentId &&
          other.title == this.title &&
          other.amountPaise == this.amountPaise &&
          other.periodStart == this.periodStart &&
          other.periodEnd == this.periodEnd &&
          other.dueDate == this.dueDate &&
          other.createdAt == this.createdAt);
}

class FeeChargesCompanion extends UpdateCompanion<FeeCharge> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> assignmentId;
  final Value<String> title;
  final Value<int> amountPaise;
  final Value<DateTime> periodStart;
  final Value<DateTime> periodEnd;
  final Value<DateTime> dueDate;
  final Value<DateTime> createdAt;
  const FeeChargesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.assignmentId = const Value.absent(),
    this.title = const Value.absent(),
    this.amountPaise = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodEnd = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FeeChargesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int assignmentId,
    required String title,
    required int amountPaise,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime dueDate,
    this.createdAt = const Value.absent(),
  })  : studentId = Value(studentId),
        assignmentId = Value(assignmentId),
        title = Value(title),
        amountPaise = Value(amountPaise),
        periodStart = Value(periodStart),
        periodEnd = Value(periodEnd),
        dueDate = Value(dueDate);
  static Insertable<FeeCharge> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? assignmentId,
    Expression<String>? title,
    Expression<int>? amountPaise,
    Expression<DateTime>? periodStart,
    Expression<DateTime>? periodEnd,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (assignmentId != null) 'assignment_id': assignmentId,
      if (title != null) 'title': title,
      if (amountPaise != null) 'amount_paise': amountPaise,
      if (periodStart != null) 'period_start': periodStart,
      if (periodEnd != null) 'period_end': periodEnd,
      if (dueDate != null) 'due_date': dueDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FeeChargesCompanion copyWith(
      {Value<int>? id,
      Value<int>? studentId,
      Value<int>? assignmentId,
      Value<String>? title,
      Value<int>? amountPaise,
      Value<DateTime>? periodStart,
      Value<DateTime>? periodEnd,
      Value<DateTime>? dueDate,
      Value<DateTime>? createdAt}) {
    return FeeChargesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      assignmentId: assignmentId ?? this.assignmentId,
      title: title ?? this.title,
      amountPaise: amountPaise ?? this.amountPaise,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (assignmentId.present) {
      map['assignment_id'] = Variable<int>(assignmentId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amountPaise.present) {
      map['amount_paise'] = Variable<int>(amountPaise.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<DateTime>(periodStart.value);
    }
    if (periodEnd.present) {
      map['period_end'] = Variable<DateTime>(periodEnd.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeeChargesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('assignmentId: $assignmentId, ')
          ..write('title: $title, ')
          ..write('amountPaise: $amountPaise, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodEnd: $periodEnd, ')
          ..write('dueDate: $dueDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstitutesTable institutes = $InstitutesTable(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $BatchesTable batches = $BatchesTable(this);
  late final $StudentAssignmentsTable studentAssignments =
      $StudentAssignmentsTable(this);
  late final $FeeChargesTable feeCharges = $FeeChargesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [institutes, classes, students, batches, studentAssignments, feeCharges];
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
typedef $$ClassesTableCreateCompanionBuilder = ClassesCompanion Function({
  Value<int> id,
  required String name,
  required String academicYear,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ClassesTableUpdateCompanionBuilder = ClassesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> academicYear,
  Value<String?> description,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$ClassesTableFilterComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableFilterComposer({
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

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ClassesTableOrderingComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableOrderingComposer({
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

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
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

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ClassesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClassesTable,
    ClassBatch,
    $$ClassesTableFilterComposer,
    $$ClassesTableOrderingComposer,
    $$ClassesTableAnnotationComposer,
    $$ClassesTableCreateCompanionBuilder,
    $$ClassesTableUpdateCompanionBuilder,
    (ClassBatch, BaseReferences<_$AppDatabase, $ClassesTable, ClassBatch>),
    ClassBatch,
    PrefetchHooks Function()> {
  $$ClassesTableTableManager(_$AppDatabase db, $ClassesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> academicYear = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ClassesCompanion(
            id: id,
            name: name,
            academicYear: academicYear,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String academicYear,
            Value<String?> description = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ClassesCompanion.insert(
            id: id,
            name: name,
            academicYear: academicYear,
            description: description,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClassesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ClassesTable,
    ClassBatch,
    $$ClassesTableFilterComposer,
    $$ClassesTableOrderingComposer,
    $$ClassesTableAnnotationComposer,
    $$ClassesTableCreateCompanionBuilder,
    $$ClassesTableUpdateCompanionBuilder,
    (ClassBatch, BaseReferences<_$AppDatabase, $ClassesTable, ClassBatch>),
    ClassBatch,
    PrefetchHooks Function()>;
typedef $$StudentsTableCreateCompanionBuilder = StudentsCompanion Function({
  Value<int> id,
  required String admissionNumber,
  required String fullName,
  Value<String?> phone,
  Value<String?> guardianName,
  Value<int?> classId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$StudentsTableUpdateCompanionBuilder = StudentsCompanion Function({
  Value<int> id,
  Value<String> admissionNumber,
  Value<String> fullName,
  Value<String?> phone,
  Value<String?> guardianName,
  Value<int?> classId,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get admissionNumber => $composableBuilder(
      column: $table.admissionNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get guardianName => $composableBuilder(
      column: $table.guardianName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get admissionNumber => $composableBuilder(
      column: $table.admissionNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullName => $composableBuilder(
      column: $table.fullName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get guardianName => $composableBuilder(
      column: $table.guardianName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get admissionNumber => $composableBuilder(
      column: $table.admissionNumber, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get guardianName => $composableBuilder(
      column: $table.guardianName, builder: (column) => column);

  GeneratedColumn<int> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StudentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentsTable,
    Student,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
    Student,
    PrefetchHooks Function()> {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> admissionNumber = const Value.absent(),
            Value<String> fullName = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> guardianName = const Value.absent(),
            Value<int?> classId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              StudentsCompanion(
            id: id,
            admissionNumber: admissionNumber,
            fullName: fullName,
            phone: phone,
            guardianName: guardianName,
            classId: classId,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String admissionNumber,
            required String fullName,
            Value<String?> phone = const Value.absent(),
            Value<String?> guardianName = const Value.absent(),
            Value<int?> classId = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              StudentsCompanion.insert(
            id: id,
            admissionNumber: admissionNumber,
            fullName: fullName,
            phone: phone,
            guardianName: guardianName,
            classId: classId,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentsTable,
    Student,
    $$StudentsTableFilterComposer,
    $$StudentsTableOrderingComposer,
    $$StudentsTableAnnotationComposer,
    $$StudentsTableCreateCompanionBuilder,
    $$StudentsTableUpdateCompanionBuilder,
    (Student, BaseReferences<_$AppDatabase, $StudentsTable, Student>),
    Student,
    PrefetchHooks Function()>;
typedef $$BatchesTableCreateCompanionBuilder = BatchesCompanion Function({
  Value<int> id,
  required int classId,
  required String name,
  Value<String?> subject,
  Value<String?> timing,
  Value<String?> teacherName,
  Value<int?> monthlyFeePaise,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$BatchesTableUpdateCompanionBuilder = BatchesCompanion Function({
  Value<int> id,
  Value<int> classId,
  Value<String> name,
  Value<String?> subject,
  Value<String?> timing,
  Value<String?> teacherName,
  Value<int?> monthlyFeePaise,
  Value<bool> isActive,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$BatchesTableFilterComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timing => $composableBuilder(
      column: $table.timing, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherName => $composableBuilder(
      column: $table.teacherName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get monthlyFeePaise => $composableBuilder(
      column: $table.monthlyFeePaise,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$BatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subject => $composableBuilder(
      column: $table.subject, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timing => $composableBuilder(
      column: $table.timing, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherName => $composableBuilder(
      column: $table.teacherName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get monthlyFeePaise => $composableBuilder(
      column: $table.monthlyFeePaise,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$BatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BatchesTable> {
  $$BatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get subject =>
      $composableBuilder(column: $table.subject, builder: (column) => column);

  GeneratedColumn<String> get timing =>
      $composableBuilder(column: $table.timing, builder: (column) => column);

  GeneratedColumn<String> get teacherName => $composableBuilder(
      column: $table.teacherName, builder: (column) => column);

  GeneratedColumn<int> get monthlyFeePaise => $composableBuilder(
      column: $table.monthlyFeePaise, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BatchesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BatchesTable,
    ClassBatchSession,
    $$BatchesTableFilterComposer,
    $$BatchesTableOrderingComposer,
    $$BatchesTableAnnotationComposer,
    $$BatchesTableCreateCompanionBuilder,
    $$BatchesTableUpdateCompanionBuilder,
    (
      ClassBatchSession,
      BaseReferences<_$AppDatabase, $BatchesTable, ClassBatchSession>
    ),
    ClassBatchSession,
    PrefetchHooks Function()> {
  $$BatchesTableTableManager(_$AppDatabase db, $BatchesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> classId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> subject = const Value.absent(),
            Value<String?> timing = const Value.absent(),
            Value<String?> teacherName = const Value.absent(),
            Value<int?> monthlyFeePaise = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BatchesCompanion(
            id: id,
            classId: classId,
            name: name,
            subject: subject,
            timing: timing,
            teacherName: teacherName,
            monthlyFeePaise: monthlyFeePaise,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int classId,
            required String name,
            Value<String?> subject = const Value.absent(),
            Value<String?> timing = const Value.absent(),
            Value<String?> teacherName = const Value.absent(),
            Value<int?> monthlyFeePaise = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              BatchesCompanion.insert(
            id: id,
            classId: classId,
            name: name,
            subject: subject,
            timing: timing,
            teacherName: teacherName,
            monthlyFeePaise: monthlyFeePaise,
            isActive: isActive,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BatchesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BatchesTable,
    ClassBatchSession,
    $$BatchesTableFilterComposer,
    $$BatchesTableOrderingComposer,
    $$BatchesTableAnnotationComposer,
    $$BatchesTableCreateCompanionBuilder,
    $$BatchesTableUpdateCompanionBuilder,
    (
      ClassBatchSession,
      BaseReferences<_$AppDatabase, $BatchesTable, ClassBatchSession>
    ),
    ClassBatchSession,
    PrefetchHooks Function()>;
typedef $$StudentAssignmentsTableCreateCompanionBuilder
    = StudentAssignmentsCompanion Function({
  Value<int> id,
  required int studentId,
  required int classId,
  Value<int?> batchId,
  required DateTime effectiveFrom,
  Value<DateTime?> effectiveTo,
  Value<String?> transferReason,
  Value<String?> endReason,
  Value<DateTime> createdAt,
});
typedef $$StudentAssignmentsTableUpdateCompanionBuilder
    = StudentAssignmentsCompanion Function({
  Value<int> id,
  Value<int> studentId,
  Value<int> classId,
  Value<int?> batchId,
  Value<DateTime> effectiveFrom,
  Value<DateTime?> effectiveTo,
  Value<String?> transferReason,
  Value<String?> endReason,
  Value<DateTime> createdAt,
});

class $$StudentAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentAssignmentsTable> {
  $$StudentAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
      column: $table.effectiveFrom, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get effectiveTo => $composableBuilder(
      column: $table.effectiveTo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transferReason => $composableBuilder(
      column: $table.transferReason,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endReason => $composableBuilder(
      column: $table.endReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$StudentAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentAssignmentsTable> {
  $$StudentAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get classId => $composableBuilder(
      column: $table.classId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get batchId => $composableBuilder(
      column: $table.batchId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
      column: $table.effectiveFrom,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get effectiveTo => $composableBuilder(
      column: $table.effectiveTo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transferReason => $composableBuilder(
      column: $table.transferReason,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endReason => $composableBuilder(
      column: $table.endReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$StudentAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentAssignmentsTable> {
  $$StudentAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<int> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
      column: $table.effectiveFrom, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveTo => $composableBuilder(
      column: $table.effectiveTo, builder: (column) => column);

  GeneratedColumn<String> get transferReason => $composableBuilder(
      column: $table.transferReason, builder: (column) => column);

  GeneratedColumn<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$StudentAssignmentsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StudentAssignmentsTable,
    StudentAssignment,
    $$StudentAssignmentsTableFilterComposer,
    $$StudentAssignmentsTableOrderingComposer,
    $$StudentAssignmentsTableAnnotationComposer,
    $$StudentAssignmentsTableCreateCompanionBuilder,
    $$StudentAssignmentsTableUpdateCompanionBuilder,
    (
      StudentAssignment,
      BaseReferences<_$AppDatabase, $StudentAssignmentsTable, StudentAssignment>
    ),
    StudentAssignment,
    PrefetchHooks Function()> {
  $$StudentAssignmentsTableTableManager(
      _$AppDatabase db, $StudentAssignmentsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentAssignmentsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<int> classId = const Value.absent(),
            Value<int?> batchId = const Value.absent(),
            Value<DateTime> effectiveFrom = const Value.absent(),
            Value<DateTime?> effectiveTo = const Value.absent(),
            Value<String?> transferReason = const Value.absent(),
            Value<String?> endReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              StudentAssignmentsCompanion(
            id: id,
            studentId: studentId,
            classId: classId,
            batchId: batchId,
            effectiveFrom: effectiveFrom,
            effectiveTo: effectiveTo,
            transferReason: transferReason,
            endReason: endReason,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int studentId,
            required int classId,
            Value<int?> batchId = const Value.absent(),
            required DateTime effectiveFrom,
            Value<DateTime?> effectiveTo = const Value.absent(),
            Value<String?> transferReason = const Value.absent(),
            Value<String?> endReason = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              StudentAssignmentsCompanion.insert(
            id: id,
            studentId: studentId,
            classId: classId,
            batchId: batchId,
            effectiveFrom: effectiveFrom,
            effectiveTo: effectiveTo,
            transferReason: transferReason,
            endReason: endReason,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StudentAssignmentsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StudentAssignmentsTable,
    StudentAssignment,
    $$StudentAssignmentsTableFilterComposer,
    $$StudentAssignmentsTableOrderingComposer,
    $$StudentAssignmentsTableAnnotationComposer,
    $$StudentAssignmentsTableCreateCompanionBuilder,
    $$StudentAssignmentsTableUpdateCompanionBuilder,
    (
      StudentAssignment,
      BaseReferences<_$AppDatabase, $StudentAssignmentsTable, StudentAssignment>
    ),
    StudentAssignment,
    PrefetchHooks Function()>;
typedef $$FeeChargesTableCreateCompanionBuilder = FeeChargesCompanion Function({
  Value<int> id,
  required int studentId,
  required int assignmentId,
  required String title,
  required int amountPaise,
  required DateTime periodStart,
  required DateTime periodEnd,
  required DateTime dueDate,
  Value<DateTime> createdAt,
});
typedef $$FeeChargesTableUpdateCompanionBuilder = FeeChargesCompanion Function({
  Value<int> id,
  Value<int> studentId,
  Value<int> assignmentId,
  Value<String> title,
  Value<int> amountPaise,
  Value<DateTime> periodStart,
  Value<DateTime> periodEnd,
  Value<DateTime> dueDate,
  Value<DateTime> createdAt,
});

class $$FeeChargesTableFilterComposer
    extends Composer<_$AppDatabase, $FeeChargesTable> {
  $$FeeChargesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get assignmentId => $composableBuilder(
      column: $table.assignmentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$FeeChargesTableOrderingComposer
    extends Composer<_$AppDatabase, $FeeChargesTable> {
  $$FeeChargesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get studentId => $composableBuilder(
      column: $table.studentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get assignmentId => $composableBuilder(
      column: $table.assignmentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get periodEnd => $composableBuilder(
      column: $table.periodEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$FeeChargesTableAnnotationComposer
    extends Composer<_$AppDatabase, $FeeChargesTable> {
  $$FeeChargesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<int> get assignmentId => $composableBuilder(
      column: $table.assignmentId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get amountPaise => $composableBuilder(
      column: $table.amountPaise, builder: (column) => column);

  GeneratedColumn<DateTime> get periodStart => $composableBuilder(
      column: $table.periodStart, builder: (column) => column);

  GeneratedColumn<DateTime> get periodEnd =>
      $composableBuilder(column: $table.periodEnd, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FeeChargesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FeeChargesTable,
    FeeCharge,
    $$FeeChargesTableFilterComposer,
    $$FeeChargesTableOrderingComposer,
    $$FeeChargesTableAnnotationComposer,
    $$FeeChargesTableCreateCompanionBuilder,
    $$FeeChargesTableUpdateCompanionBuilder,
    (FeeCharge, BaseReferences<_$AppDatabase, $FeeChargesTable, FeeCharge>),
    FeeCharge,
    PrefetchHooks Function()> {
  $$FeeChargesTableTableManager(_$AppDatabase db, $FeeChargesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FeeChargesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FeeChargesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FeeChargesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> studentId = const Value.absent(),
            Value<int> assignmentId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<int> amountPaise = const Value.absent(),
            Value<DateTime> periodStart = const Value.absent(),
            Value<DateTime> periodEnd = const Value.absent(),
            Value<DateTime> dueDate = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FeeChargesCompanion(
            id: id,
            studentId: studentId,
            assignmentId: assignmentId,
            title: title,
            amountPaise: amountPaise,
            periodStart: periodStart,
            periodEnd: periodEnd,
            dueDate: dueDate,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int studentId,
            required int assignmentId,
            required String title,
            required int amountPaise,
            required DateTime periodStart,
            required DateTime periodEnd,
            required DateTime dueDate,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FeeChargesCompanion.insert(
            id: id,
            studentId: studentId,
            assignmentId: assignmentId,
            title: title,
            amountPaise: amountPaise,
            periodStart: periodStart,
            periodEnd: periodEnd,
            dueDate: dueDate,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FeeChargesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FeeChargesTable,
    FeeCharge,
    $$FeeChargesTableFilterComposer,
    $$FeeChargesTableOrderingComposer,
    $$FeeChargesTableAnnotationComposer,
    $$FeeChargesTableCreateCompanionBuilder,
    $$FeeChargesTableUpdateCompanionBuilder,
    (FeeCharge, BaseReferences<_$AppDatabase, $FeeChargesTable, FeeCharge>),
    FeeCharge,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstitutesTableTableManager get institutes =>
      $$InstitutesTableTableManager(_db, _db.institutes);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$BatchesTableTableManager get batches =>
      $$BatchesTableTableManager(_db, _db.batches);
  $$StudentAssignmentsTableTableManager get studentAssignments =>
      $$StudentAssignmentsTableTableManager(_db, _db.studentAssignments);
  $$FeeChargesTableTableManager get feeCharges =>
      $$FeeChargesTableTableManager(_db, _db.feeCharges);
}
