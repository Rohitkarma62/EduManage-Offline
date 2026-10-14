import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('batches belong to their parent class and preserve paise amounts', () async {
    final classId = await database.saveClass(
      name: 'Class 10 A',
      academicYear: '2026-2027',
    );
    final batchId = await database.saveBatch(
      classId: classId,
      name: 'Morning',
      subject: 'Mathematics',
      timing: '8:00 AM',
      teacherName: 'Ravi',
      monthlyFeePaise: 125050,
    );
    final batch = await database.getBatch(batchId);
    expect(batch?.classId, classId);
    expect(batch?.monthlyFeePaise, 125050);
    expect(await database.batchExists(classId: classId, name: ' Morning '), isTrue);
    expect(await database.getBatches(classId), hasLength(1));
    await database.setBatchActive(batchId, isActive: false);
    expect((await database.getBatch(batchId))?.isActive, isFalse);
    expect(await database.countBatches(classId), 1);
  });
  test('database rejects negative batch fees on insert and update', () async {
    final classId = await database.saveClass(
      name: 'Class 10 A',
      academicYear: '2026-2027',
    );
    await expectLater(
      database.saveBatch(
        classId: classId,
        name: 'Invalid fee',
        monthlyFeePaise: -1,
      ),
      throwsA(anything),
    );

    final batchId = await database.saveBatch(
      classId: classId,
      name: 'Valid fee',
      monthlyFeePaise: 10000,
    );
    await expectLater(
      (database.update(database.batches)
            ..where((row) => row.id.equals(batchId)))
          .write(const BatchesCompanion(monthlyFeePaise: Value(-5))),
      throwsA(anything),
    );
  });

  test('batch names are duplicate case-insensitively within a class', () async {
    final classId = await database.saveClass(
      name: 'Class 10 A',
      academicYear: '2026-2027',
    );
    await database.saveBatch(classId: classId, name: 'Morning');
    expect(
      await database.batchExists(classId: classId, name: ' morning '),
      isTrue,
    );
    await expectLater(
      database.saveBatch(classId: classId, name: 'MORNING'),
      throwsA(anything),
    );
  });

  test('class deletion unassigns students but is restricted when batches exist',
      () async {
    final classId = await database.saveClass(
      name: 'Class 10 A',
      academicYear: '2026-2027',
    );
    final studentId = await database.saveStudent(
      admissionNumber: 'ADM-DEL-1',
      fullName: 'Student One',
      classId: classId,
    );

    await (database.delete(database.classes)
          ..where((row) => row.id.equals(classId)))
        .go();
    expect((await database.getStudent(studentId))?.classId, isNull);

    final classWithBatch = await database.saveClass(
      name: 'Class 10 B',
      academicYear: '2026-2027',
    );
    await database.saveBatch(classId: classWithBatch, name: 'Morning');
    await expectLater(
      (database.delete(database.classes)
            ..where((row) => row.id.equals(classWithBatch)))
          .go(),
      throwsA(anything),
    );
    expect(await database.getClass(classWithBatch), isNotNull);
  });
}
