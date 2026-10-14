import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/institutes.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Institutes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'edumanage_offline'));

  @override
  int get schemaVersion => 1;

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
}
