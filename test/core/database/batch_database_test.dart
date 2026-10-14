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
}
