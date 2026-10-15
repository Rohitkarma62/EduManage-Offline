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

  Future<(int, int, int)> createAssignedStudent() async {
    final classId = await database.saveClass(
      name: 'Class 10',
      academicYear: '2026-2027',
    );
    final studentId = await database.saveStudent(
      admissionNumber: 'ADM-001',
      fullName: 'Test Student',
      classId: classId,
    );
    final assignment = await database.getCurrentStudentAssignment(studentId);
    return (studentId, assignment!.id, classId);
  }

  test('stores fee charges in paise against the historical assignment',
      () async {
    final (studentId, assignmentId, _) = await createAssignedStudent();
    final start = DateTime(2026, 10, 1);
    final end = DateTime(2026, 11, 1);
    final due = DateTime(2026, 10, 10);

    final id = await database.createFeeCharge(
      studentId: studentId,
      assignmentId: assignmentId,
      title: 'October tuition',
      amountPaise: 125050,
      periodStart: start,
      periodEnd: end,
      dueDate: due,
    );

    final charges = await database.getFeeChargesForStudent(studentId);
    expect(charges, hasLength(1));
    expect(charges.single.id, id);
    expect(charges.single.title, 'October tuition');
    expect(charges.single.amountPaise, 125050);
    expect(charges.single.periodStart, start);
    expect(charges.single.periodEnd, end);
    expect(charges.single.dueDate, due);
  });

  test('rejects non-positive fee amounts before inserting', () async {
    final (studentId, assignmentId, _) = await createAssignedStudent();

    await expectLater(
      database.createFeeCharge(
        studentId: studentId,
        assignmentId: assignmentId,
        title: 'Tuition',
        amountPaise: 0,
        periodStart: DateTime(2026, 10, 1),
        periodEnd: DateTime(2026, 11, 1),
        dueDate: DateTime(2026, 10, 10),
      ),
      throwsArgumentError,
    );
    expect(await database.getFeeChargesForStudent(studentId), isEmpty);
  });

  test('rejects an empty title and invalid fee period', () async {
    final (studentId, assignmentId, _) = await createAssignedStudent();

    await expectLater(
      database.createFeeCharge(
        studentId: studentId,
        assignmentId: assignmentId,
        title: '  ',
        amountPaise: 100,
        periodStart: DateTime(2026, 10, 1),
        periodEnd: DateTime(2026, 11, 1),
        dueDate: DateTime(2026, 10, 10),
      ),
      throwsArgumentError,
    );
    await expectLater(
      database.createFeeCharge(
        studentId: studentId,
        assignmentId: assignmentId,
        title: 'Tuition',
        amountPaise: 100,
        periodStart: DateTime(2026, 11, 1),
        periodEnd: DateTime(2026, 11, 1),
        dueDate: DateTime(2026, 10, 10),
      ),
      throwsArgumentError,
    );
  });

  test('database guard rejects assignment belonging to another student',
      () async {
    final (studentId, assignmentId, _) = await createAssignedStudent();
    final otherClassId = await database.saveClass(
      name: 'Class 9',
      academicYear: '2026-2027',
    );
    final otherStudentId = await database.saveStudent(
      admissionNumber: 'ADM-002',
      fullName: 'Other Student',
      classId: otherClassId,
    );

    await expectLater(
      database.into(database.feeCharges).insert(
            FeeChargesCompanion.insert(
              studentId: otherStudentId,
              assignmentId: assignmentId,
              title: 'Invalid link',
              amountPaise: 100,
              periodStart: DateTime(2026, 10, 1),
              periodEnd: DateTime(2026, 11, 1),
              dueDate: DateTime(2026, 10, 10),
            ),
          ),
      throwsA(anything),
    );
    expect(await database.getFeeChargesForStudent(studentId), isEmpty);
  });
}
