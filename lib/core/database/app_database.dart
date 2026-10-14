import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/institutes.dart';
import 'tables/students.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Institutes, Students])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'edumanage_offline'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(students);
        },
      );

  Future<Institute?> getInstitute() =>
      (select(institutes)..limit(1)).getSingleOrNull();

  Future<void> saveInstitute(
      {required String name,
      required String academicYear,
      String? phone}) async {
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

  Future<int> saveStudent(
      {int? id,
      required String admissionNumber,
      required String fullName,
      String? phone,
      String? guardianName}) async {
    final now = DateTime.now();
    final values = StudentsCompanion(
      admissionNumber: Value(admissionNumber.trim()),
      fullName: Value(fullName.trim()),
      phone: Value(phone == null || phone.trim().isEmpty ? null : phone.trim()),
      guardianName: Value(guardianName == null || guardianName.trim().isEmpty
          ? null
          : guardianName.trim()),
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
