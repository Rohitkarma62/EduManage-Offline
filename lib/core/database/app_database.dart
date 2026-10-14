import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/batches.dart';
import 'tables/classes.dart';
import 'tables/institutes.dart';
import 'tables/students.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Institutes, Classes, Students, Batches])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'edumanage_offline'));

  @override
  int get schemaVersion => 5;

  Future<void> _installBatchFeeGuards() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS batches_fee_nonnegative_insert
      BEFORE INSERT ON batches
      WHEN NEW.monthly_fee_paise IS NOT NULL AND NEW.monthly_fee_paise < 0
      BEGIN
        SELECT RAISE(ABORT, 'monthly_fee_paise must be non-negative');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS batches_fee_nonnegative_update
      BEFORE UPDATE OF monthly_fee_paise ON batches
      WHEN NEW.monthly_fee_paise IS NOT NULL AND NEW.monthly_fee_paise < 0
      BEGIN
        SELECT RAISE(ABORT, 'monthly_fee_paise must be non-negative');
      END
    ''');
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          // SQLite foreign-key enforcement is connection-local and disabled by
          // default. Enable it on every opened connection before app queries run.
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          await _installBatchFeeGuards();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(students);
          if (from < 3) {
            await m.createTable(classes);
            await m.addColumn(students, students.classId);
          }
          if (from < 4) await m.createTable(batches);
          if (from < 5) await _installBatchFeeGuards();
        },
      );

  Future<Institute?> getInstitute() =>
      (select(institutes)..limit(1)).getSingleOrNull();

  Future<void> saveInstitute({
    required String name,
    required String academicYear,
    String? phone,
  }) async {
    final existing = await getInstitute();
    final values = InstitutesCompanion(
      name: Value(name.trim()),
      academicYear: Value(academicYear.trim()),
      phone: Value(phone == null || phone.trim().isEmpty ? null : phone.trim()),
    );
    if (existing == null) {
      await into(institutes).insert(values);
    } else {
      await (update(institutes)..where((row) => row.id.equals(existing.id)))
          .write(values);
    }
  }

  Future<List<ClassBatch>> searchClasses(String query) {
    final normalized = query.trim();
    final statement = select(classes)
      ..orderBy([
        (row) => OrderingTerm.asc(row.academicYear),
        (row) => OrderingTerm.asc(row.name),
      ]);
    if (normalized.isNotEmpty) {
      statement.where((row) =>
          row.name.like('%$normalized%') |
          row.academicYear.like('%$normalized%') |
          row.description.like('%$normalized%'));
    }
    return statement.get();
  }

  Future<ClassBatch?> getClass(int id) =>
      (select(classes)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<bool> classExists({
    required String name,
    required String academicYear,
    int? excludingId,
  }) async {
    final normalizedName = name.trim().toLowerCase();
    final normalizedYear = academicYear.trim().toLowerCase();
    final existing = await (select(classes)
          ..where((row) => row.id.isNotIn([excludingId ?? -1])))
        .get();
    return existing.any((row) =>
        row.id != excludingId &&
        row.name.trim().toLowerCase() == normalizedName &&
        row.academicYear.trim().toLowerCase() == normalizedYear);
  }

  Future<int> saveClass({
    int? id,
    required String name,
    required String academicYear,
    String? description,
  }) async {
    if (await classExists(
      name: name,
      academicYear: academicYear,
      excludingId: id,
    )) {
      throw StateError('A class with this name already exists for this year');
    }
    final now = DateTime.now();
    final values = ClassesCompanion(
      name: Value(name.trim()),
      academicYear: Value(academicYear.trim()),
      description: Value(
        description == null || description.trim().isEmpty
            ? null
            : description.trim(),
      ),
      updatedAt: Value(now),
    );
    if (id == null) return into(classes).insert(values);
    await (update(classes)..where((row) => row.id.equals(id))).write(values);
    return id;
  }

  Future<void> setClassActive(int id, {required bool isActive}) async {
    await (update(classes)..where((row) => row.id.equals(id))).write(
      ClassesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ClassBatchSession>> getBatches(int classId) => (select(batches)
        ..where((row) => row.classId.equals(classId))
        ..orderBy([(row) => OrderingTerm.asc(row.name)]))
      .get();

  Future<ClassBatchSession?> getBatch(int id) =>
      (select(batches)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<bool> batchExists({
    required int classId,
    required String name,
    int? excludingId,
  }) async {
    final normalizedName = name.trim().toLowerCase();
    final existing = await (select(batches)
          ..where((row) => row.classId.equals(classId)))
        .get();
    return existing.any((row) =>
        row.id != excludingId &&
        row.name.trim().toLowerCase() == normalizedName);
  }

  Future<int> saveBatch({
    int? id,
    required int classId,
    required String name,
    String? subject,
    String? timing,
    String? teacherName,
    int? monthlyFeePaise,
  }) async {
    if (await batchExists(
      classId: classId,
      name: name,
      excludingId: id,
    )) {
      throw StateError('A batch with this name already exists in this class');
    }
    String? optionalText(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    final values = BatchesCompanion(
      classId: Value(classId),
      name: Value(name.trim()),
      subject: Value(optionalText(subject)),
      timing: Value(optionalText(timing)),
      teacherName: Value(optionalText(teacherName)),
      monthlyFeePaise: Value(monthlyFeePaise),
      updatedAt: Value(DateTime.now()),
    );
    if (id == null) return into(batches).insert(values);
    await (update(batches)..where((row) => row.id.equals(id))).write(values);
    return id;
  }

  Future<void> setBatchActive(int id, {required bool isActive}) async {
    await (update(batches)..where((row) => row.id.equals(id))).write(
      BatchesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> countBatches(int classId) async {
    final count = batches.id.count();
    final query = selectOnly(batches)
      ..addColumns([count])
      ..where(batches.classId.equals(classId));
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<List<Student>> searchStudents(String query) {
    final normalized = query.trim();
    final statement = select(students)
      ..orderBy([(row) => OrderingTerm.asc(row.fullName)]);
    if (normalized.isNotEmpty) {
      statement.where((row) =>
          row.fullName.like('%$normalized%') |
          row.admissionNumber.like('%$normalized%'));
    }
    return statement.get();
  }

  Future<Student?> getStudent(int id) =>
      (select(students)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<bool> studentAdmissionNumberExists({
    required String admissionNumber,
    int? excludingId,
  }) async {
    final normalized = admissionNumber.trim().toUpperCase();
    final existing = await (select(students)
          ..where((row) => row.admissionNumber.equals(normalized)))
        .getSingleOrNull();
    return existing != null && existing.id != excludingId;
  }

  Future<int> saveStudent({
    int? id,
    required String admissionNumber,
    required String fullName,
    String? phone,
    String? guardianName,
    int? classId,
  }) async {
    final now = DateTime.now();
    final values = StudentsCompanion(
      admissionNumber: Value(admissionNumber.trim().toUpperCase()),
      fullName: Value(fullName.trim()),
      phone: Value(phone == null || phone.trim().isEmpty ? null : phone.trim()),
      guardianName: Value(guardianName == null || guardianName.trim().isEmpty
          ? null
          : guardianName.trim()),
      classId: Value(classId),
      updatedAt: Value(now),
    );
    if (id == null) return into(students).insert(values);
    await (update(students)..where((row) => row.id.equals(id))).write(values);
    return id;
  }

  Future<void> setStudentActive(int id, {required bool isActive}) async {
    await (update(students)..where((row) => row.id.equals(id))).write(
      StudentsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
