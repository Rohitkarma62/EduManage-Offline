import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  setUp(() { database = AppDatabase(NativeDatabase.memory()); });
  tearDown(() async { await database.close(); });

  test('saves and searches student by name or admission number', () async {
    await database.saveStudent(admissionNumber: 'ADM-001', fullName: 'Asha Sharma', phone: '9876543210', guardianName: 'Ravi Sharma');
    await database.saveStudent(admissionNumber: 'ADM-002', fullName: 'Kabir Verma');
    expect((await database.searchStudents('Asha')).map((s) => s.admissionNumber), ['ADM-001']);
    expect((await database.searchStudents('ADM-002')).single.fullName, 'Kabir Verma');
    final student = (await database.searchStudents('')).first;
    expect(student.phone, '9876543210');
    expect(student.guardianName, 'Ravi Sharma');
    expect(student.isActive, isTrue);
  });

  test('rejects duplicate admission numbers', () async {
    await database.saveStudent(admissionNumber: 'ADM-001', fullName: 'Asha Sharma');
    await expectLater(database.saveStudent(admissionNumber: 'ADM-001', fullName: 'Another Student'), throwsA(anything));
  });

  test('keeps institute data when student table is used', () async {
    await database.saveInstitute(name: 'North Star', academicYear: '2026-2027');
    await database.saveStudent(admissionNumber: 'ADM-001', fullName: 'Asha Sharma');
    expect((await database.getInstitute())?.name, 'North Star');
  });
}
