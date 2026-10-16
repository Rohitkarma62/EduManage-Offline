import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('saves daily attendance and updates an existing mark', () async {
    final firstId = await database.saveStudent(
      admissionNumber: 'A-001',
      fullName: 'Aarav Sharma',
    );
    final secondId = await database.saveStudent(
      admissionNumber: 'A-002',
      fullName: 'Diya Patel',
    );
    final date = DateTime(2026, 10, 16);

    await database.saveAttendanceForDate(date, {
      firstId: 'present',
      secondId: 'absent',
    });
    await database.saveAttendanceForDate(date, {
      firstId: 'leave',
    });

    final rows = await database.getAttendanceForDate(date);
    expect(rows, hasLength(2));
    expect(rows.first.read<int>('student_id'), firstId);
    expect(rows.first.read<String?>('attendance_status'), 'leave');
    expect(rows.last.read<String?>('attendance_status'), 'absent');

    expect(await database.getAttendanceSummary(date), {
      'present': 0,
      'absent': 1,
      'leave': 1,
      'unmarked': 0,
    });
  });

  test('attendance is separated by date and rejects invalid statuses', () async {
    final studentId = await database.saveStudent(
      admissionNumber: 'A-003',
      fullName: 'Kabir Singh',
    );
    final date = DateTime(2026, 10, 16);

    await database.saveAttendanceForDate(date, {studentId: 'present'});
    await expectLater(
      database.saveAttendanceForDate(date, {studentId: 'late'}),
      throwsArgumentError,
    );

    final nextDay = await database.getAttendanceForDate(
      date.add(const Duration(days: 1)),
    );
    expect(nextDay.single.read<String?>('attendance_status'), isNull);
  });
}
