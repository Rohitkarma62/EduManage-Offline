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

  test('saves and searches student by name or admission number', () async {
    await database.saveStudent(
      admissionNumber: 'ADM-001',
      fullName: 'Asha Sharma',
      phone: '9876543210',
      guardianName: 'Ravi Sharma',
    );
    await database.saveStudent(
      admissionNumber: 'ADM-002',
      fullName: 'Kabir Verma',
    );
    expect(
      (await database.searchStudents('Asha')).map((s) => s.admissionNumber),
      ['ADM-001'],
    );
    expect(
      (await database.searchStudents('ADM-002')).single.fullName,
      'Kabir Verma',
    );
    final student = (await database.searchStudents('')).first;
    expect(student.phone, '9876543210');
    expect(student.guardianName, 'Ravi Sharma');
    expect(student.isActive, isTrue);
  });

  test('normalizes admission numbers and detects duplicates case-insensitively', () async {
    final id = await database.saveStudent(
      admissionNumber: '  adm-001 ',
      fullName: 'Asha Sharma',
    );
    expect((await database.getStudent(id))?.admissionNumber, 'ADM-001');
    expect(
      await database.studentAdmissionNumberExists(
        admissionNumber: 'adm-001',
      ),
      isTrue,
    );
    expect(
      await database.studentAdmissionNumberExists(
        admissionNumber: ' ADM-001 ',
        excludingId: id,
      ),
      isFalse,
    );
    expect(
      await database.studentAdmissionNumberExists(
        admissionNumber: 'ADM-002',
        excludingId: id,
      ),
      isFalse,
    );
    await expectLater(
      database.saveStudent(
        admissionNumber: 'adm-001',
        fullName: 'Another Student',
      ),
      throwsA(anything),
    );
  });

  test('edits student details and deactivates/reactivates without deleting', () async {
    final id = await database.saveStudent(
      admissionNumber: 'ADM-001',
      fullName: 'Asha Sharma',
    );
    await database.saveStudent(
      id: id,
      admissionNumber: 'ADM-001',
      fullName: 'Asha Verma',
      phone: '9876543210',
    );
    expect((await database.getStudent(id))?.fullName, 'Asha Verma');
    expect((await database.getStudent(id))?.phone, '9876543210');

    await database.setStudentActive(id, isActive: false);
    expect((await database.getStudent(id))?.isActive, isFalse);
    await database.setStudentActive(id, isActive: true);
    expect((await database.getStudent(id))?.isActive, isTrue);
    expect(await database.searchStudents('ADM-001'), hasLength(1));
  });

  test('keeps institute data when student table is used', () async {
    await database.saveInstitute(
      name: 'North Star',
      academicYear: '2026-2027',
    );
    await database.saveStudent(
      admissionNumber: 'ADM-001',
      fullName: 'Asha Sharma',
    );
    expect((await database.getInstitute())?.name, 'North Star');
  });

  test('creates, searches, edits, and deactivates classes', () async {
    final id = await database.saveClass(
      name: 'Class 10 A',
      academicYear: '2026-2027',
      description: 'Morning section',
    );
    expect(await database.classExists(
      name: 'Class 10 A',
      academicYear: '2026-2027',
    ), isTrue);
    expect(await database.classExists(
      name: 'Class 10 A',
      academicYear: '2026-2027',
      excludingId: id,
    ), isFalse);
    expect((await database.searchClasses('Morning')).single.id, id);

    await database.saveClass(
      id: id,
      name: 'Class 10 B',
      academicYear: '2026-2027',
    );
    expect((await database.getClass(id))?.name, 'Class 10 B');
    await database.setClassActive(id, isActive: false);
    expect((await database.getClass(id))?.isActive, isFalse);
    await database.setClassActive(id, isActive: true);
    expect((await database.getClass(id))?.isActive, isTrue);
  });

  test('assigns students to a class without breaking existing student data', () async {
    final classId = await database.saveClass(
      name: 'NEET Morning',
      academicYear: '2026-2027',
    );
    final studentId = await database.saveStudent(
      admissionNumber: 'ADM-010',
      fullName: 'Asha Sharma',
      classId: classId,
    );
    expect((await database.getStudent(studentId))?.classId, classId);

    await database.saveStudent(
      id: studentId,
      admissionNumber: 'ADM-010',
      fullName: 'Asha Sharma',
      classId: null,
    );
    expect((await database.getStudent(studentId))?.classId, isNull);
  });
}
