import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('upgrades a v3 database without losing institute, class, or student data',
      () async {
    final executor = NativeDatabase.memory(
      setup: (db) {
        db.execute('''
          CREATE TABLE institutes (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            academic_year TEXT NOT NULL,
            phone TEXT,
            currency_code TEXT NOT NULL DEFAULT 'INR',
            created_at INTEGER NOT NULL DEFAULT 0
          )
        ''');
        db.execute('''
          CREATE TABLE classes (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            academic_year TEXT NOT NULL,
            description TEXT,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0,
            UNIQUE(name, academic_year)
          )
        ''');
        db.execute('''
          CREATE TABLE students (
            id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
            admission_number TEXT NOT NULL UNIQUE,
            full_name TEXT NOT NULL,
            phone TEXT,
            guardian_name TEXT,
            class_id INTEGER REFERENCES classes(id) ON DELETE SET NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            created_at INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL DEFAULT 0
          )
        ''');
        db.execute(
          "INSERT INTO institutes (id, name, academic_year, currency_code, created_at) VALUES (1, 'North Star', '2026-2027', 'INR', 0)",
        );
        db.execute(
          "INSERT INTO classes (id, name, academic_year, created_at, updated_at) VALUES (7, 'Class 10 A', '2026-2027', 0, 0)",
        );
        db.execute(
          "INSERT INTO students (id, admission_number, full_name, class_id, created_at, updated_at) VALUES (9, 'ADM-009', 'Asha Sharma', 7, 0, 0)",
        );
        db.execute('PRAGMA user_version = 3');
      },
    );
    final database = AppDatabase(executor);
    addTearDown(database.close);

    final institute = await database.getInstitute();
    final student = await database.getStudent(9);
    final classRecord = await database.getClass(7);

    expect(institute?.name, 'North Star');
    expect(student?.admissionNumber, 'ADM-009');
    expect(student?.classId, 7);
    expect(classRecord?.name, 'Class 10 A');
    expect(await database.getBatches(7), isEmpty);
    final migratedHistory = await database.getStudentAssignmentHistory(9);
    expect(migratedHistory, hasLength(1));
    expect(migratedHistory.single.classId, 7);
    expect(migratedHistory.single.effectiveTo, isNull);

    final batchId = await database.saveBatch(
      classId: 7,
      name: 'Morning',
      monthlyFeePaise: 25000,
    );
    expect((await database.getBatch(batchId))?.monthlyFeePaise, 25000);
  });
}
