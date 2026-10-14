import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/batches.dart';
import 'tables/classes.dart';
import 'tables/institutes.dart';
import 'tables/students.dart';
import 'tables/student_assignments.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Institutes, Classes, Students, Batches, StudentAssignments])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'edumanage_offline'));

  @override
  int get schemaVersion => 7;

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

  Future<void> _installIntegrityGuards() async {
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS classes_normalized_duplicate_insert
      BEFORE INSERT ON classes
      WHEN EXISTS (
        SELECT 1 FROM classes c
        WHERE lower(trim(c.name)) = lower(trim(NEW.name))
          AND lower(trim(c.academic_year)) = lower(trim(NEW.academic_year))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate class name for academic year'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS classes_normalized_duplicate_update
      BEFORE UPDATE OF name, academic_year ON classes
      WHEN EXISTS (
        SELECT 1 FROM classes c
        WHERE c.id != NEW.id
          AND lower(trim(c.name)) = lower(trim(NEW.name))
          AND lower(trim(c.academic_year)) = lower(trim(NEW.academic_year))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate class name for academic year'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_normalized_duplicate_insert
      BEFORE INSERT ON batches
      WHEN EXISTS (
        SELECT 1 FROM batches b
        WHERE b.class_id = NEW.class_id
          AND lower(trim(b.name)) = lower(trim(NEW.name))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate batch name for class'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_normalized_duplicate_update
      BEFORE UPDATE OF class_id, name ON batches
      WHEN EXISTS (
        SELECT 1 FROM batches b
        WHERE b.id != NEW.id
          AND b.class_id = NEW.class_id
          AND lower(trim(b.name)) = lower(trim(NEW.name))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate batch name for class'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_parent_class_insert
      BEFORE INSERT ON batches
      WHEN NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'batch parent class does not exist'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_parent_class_update
      BEFORE UPDATE OF class_id ON batches
      WHEN NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'batch parent class does not exist'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS students_class_reference_insert
      BEFORE INSERT ON students
      WHEN NEW.class_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'student class does not exist'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS students_class_reference_update
      BEFORE UPDATE OF class_id ON students
      WHEN NEW.class_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'student class does not exist'); END
    """);
  }

  Future<void> _installAssignmentGuards() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS student_assignments_one_current
      ON student_assignments(student_id) WHERE effective_to IS NULL
    ''');
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_valid_dates_insert
      BEFORE INSERT ON student_assignments
      WHEN NEW.effective_to IS NOT NULL AND NEW.effective_to <= NEW.effective_from
      BEGIN SELECT RAISE(ABORT, 'assignment end must be after start'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_valid_dates_update
      BEFORE UPDATE OF effective_from, effective_to ON student_assignments
      WHEN NEW.effective_to IS NOT NULL AND NEW.effective_to <= NEW.effective_from
      BEGIN SELECT RAISE(ABORT, 'assignment end must be after start'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_batch_class_insert
      BEFORE INSERT ON student_assignments
      WHEN NEW.batch_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM batches b
        WHERE b.id = NEW.batch_id AND b.class_id = NEW.class_id
      )
      BEGIN SELECT RAISE(ABORT, 'assigned batch must belong to assigned class'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_batch_class_update
      BEFORE UPDATE OF batch_id, class_id ON student_assignments
      WHEN NEW.batch_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM batches b
        WHERE b.id = NEW.batch_id AND b.class_id = NEW.class_id
      )
      BEGIN SELECT RAISE(ABORT, 'assigned batch must belong to assigned class'); END
    """);
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _installBatchFeeGuards();
          await _installIntegrityGuards();
          await _installAssignmentGuards();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(students);
          if (from < 3) {
            await m.createTable(classes);
            await m.addColumn(students, students.classId);
          }
          if (from < 4) await m.createTable(batches);
          if (from < 5) await _installBatchFeeGuards();
          if (from < 6) await _installIntegrityGuards();
          if (from < 7) {
            await m.createTable(studentAssignments);
            await customStatement('''
              INSERT INTO student_assignments
                (student_id, class_id, batch_id, effective_from, effective_to, transfer_reason, created_at)
              SELECT id, class_id, NULL, created_at, NULL, 'Migrated existing class assignment', created_at
              FROM students
              WHERE class_id IS NOT NULL
            ''');
            await _installAssignmentGuards();
          }
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
    final variables = <Variable<Object>>[
      Variable.withString(name.trim().toLowerCase()),
      Variable.withString(academicYear.trim().toLowerCase()),
    ];
    final exclusion = excludingId == null ? '' : 'AND id != ?';
    if (excludingId != null) variables.add(Variable.withInt(excludingId));
    final existing = await customSelect(
      'SELECT 1 AS matched FROM classes '
      'WHERE lower(trim(name)) = ? AND lower(trim(academic_year)) = ? '
      '$exclusion LIMIT 1',
      variables: variables,
    ).getSingleOrNull();
    return existing != null;
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

  /// Deletes a class only when it has no batches, and safely unassigns its students.
  /// This explicit transaction keeps the app's deletion policy consistent even
  /// when a SQLite executor does not enable foreign-key enforcement.
  Future<void> deleteClass(int id) async {
    await transaction(() async {
      final batchCount = await countBatches(id);
      if (batchCount > 0) {
        throw StateError('A class with batches cannot be deleted');
      }

      await (update(students)..where((row) => row.classId.equals(id))).write(
        StudentsCompanion(
          classId: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await (delete(classes)..where((row) => row.id.equals(id))).go();
    });
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
    final variables = <Variable<Object>>[
      Variable.withInt(classId),
      Variable.withString(name.trim().toLowerCase()),
    ];
    final exclusion = excludingId == null ? '' : 'AND id != ?';
    if (excludingId != null) variables.add(Variable.withInt(excludingId));
    final existing = await customSelect(
      'SELECT 1 AS matched FROM batches WHERE class_id = ? '
      'AND lower(trim(name)) = ? $exclusion LIMIT 1',
      variables: variables,
    ).getSingleOrNull();
    return existing != null;
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

  Future<List<StudentAssignment>> getStudentAssignmentHistory(int studentId) =>
      (select(studentAssignments)
            ..where((row) => row.studentId.equals(studentId))
            ..orderBy([(row) => OrderingTerm.asc(row.effectiveFrom)]))
          .get();

  Future<StudentAssignment?> getCurrentStudentAssignment(int studentId) =>
      (select(studentAssignments)
            ..where((row) =>
                row.studentId.equals(studentId) & row.effectiveTo.isNull()))
          .getSingleOrNull();

  /// Transfers a student without overwriting their previous placement.
  /// The end of the old assignment is exclusive, matching the new start.
  Future<int> assignStudentToClass({
    required int studentId,
    required int classId,
    int? batchId,
    required DateTime effectiveFrom,
    String? reason,
  }) async {
    final normalizedReason =
        reason == null || reason.trim().isEmpty ? null : reason.trim();
    if (normalizedReason != null && normalizedReason.length > 240) {
      throw ArgumentError('Transfer reason must be 240 characters or fewer');
    }
    return transaction(() async {
      final student = await getStudent(studentId);
      if (student == null) throw StateError('Student does not exist');
      final targetClass = await getClass(classId);
      if (targetClass == null) throw StateError('Target class does not exist');
      if (batchId != null) {
        final targetBatch = await getBatch(batchId);
        if (targetBatch == null || targetBatch.classId != classId) {
          throw StateError('Selected batch must belong to the target class');
        }
      }

      final current = await getCurrentStudentAssignment(studentId);
      if (current != null) {
        if (!effectiveFrom.isAfter(current.effectiveFrom)) {
          throw StateError('Transfer date must be after the current assignment start');
        }
        await (update(studentAssignments)
              ..where((row) => row.id.equals(current.id)))
            .write(StudentAssignmentsCompanion(
          effectiveTo: Value(effectiveFrom),
        ));
      } else if (student.classId != null) {
        // A legacy/unmigrated assignment should never be silently discarded.
        throw StateError('Student has a class but no assignment history; review data first');
      }

      final assignmentId = await into(studentAssignments).insert(
        StudentAssignmentsCompanion.insert(
          studentId: studentId,
          classId: classId,
          batchId: Value(batchId),
          effectiveFrom: effectiveFrom,
          transferReason: Value(normalizedReason),
        ),
      );
      await (update(students)..where((row) => row.id.equals(studentId))).write(
        StudentsCompanion(
          classId: Value(classId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return assignmentId;
    });
  }

  Future<void> clearStudentAssignment({
    required int studentId,
    required DateTime effectiveTo,
    String? reason,
  }) async {
    final normalizedReason =
        reason == null || reason.trim().isEmpty ? null : reason.trim();
    await transaction(() async {
      final student = await getStudent(studentId);
      if (student == null) throw StateError('Student does not exist');
      final current = await getCurrentStudentAssignment(studentId);
      if (current == null) {
        if (student.classId != null) {
          throw StateError('Student has a class but no assignment history; review data first');
        }
        return;
      }
      if (!effectiveTo.isAfter(current.effectiveFrom)) {
        throw StateError('End date must be after the assignment start');
      }
      await (update(studentAssignments)
            ..where((row) => row.id.equals(current.id)))
          .write(StudentAssignmentsCompanion(
        effectiveTo: Value(effectiveTo),
        transferReason: Value(normalizedReason),
      ));
      await (update(students)..where((row) => row.id.equals(studentId))).write(
        StudentsCompanion(
          classId: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
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
