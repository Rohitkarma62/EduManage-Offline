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

  Future<int> createClass(String name) => database.saveClass(
        name: name,
        academicYear: '2026-2027',
      );

  Future<int> createStudent({int? classId}) => database.saveStudent(
        admissionNumber: 'ADM-' + DateTime.now().microsecondsSinceEpoch.toString(),
        fullName: 'Test Student',
        classId: classId,
      );

  test('class assignment and transfer preserve effective-dated history',
      () async {
    final firstClass = await createClass('Class A');
    final secondClass = await createClass('Class B');
    final studentId = await createStudent(classId: firstClass);
    final original = await database.getCurrentStudentAssignment(studentId);

    expect(original, isNotNull);
    expect(original!.classId, firstClass);
    expect(original.effectiveTo, isNull);

    final transferDate = DateTime.now();
    await database.assignStudentToClass(
      studentId: studentId,
      classId: secondClass,
      effectiveFrom: transferDate,
      reason: 'Academic promotion',
    );

    final history = await database.getStudentAssignmentHistory(studentId);
    final current = await database.getCurrentStudentAssignment(studentId);
    final student = await database.getStudent(studentId);

    expect(history, hasLength(2));
    expect(history.first.classId, firstClass);
    expect(history.first.effectiveTo, isNotNull);
    expect(history.last.classId, secondClass);
    expect(history.last.transferReason, 'Academic promotion');
    expect(current?.classId, secondClass);
    expect(student?.classId, secondClass);
  });

  test('rejects a transfer date that is not after current assignment start',
      () async {
    final firstClass = await createClass('Class A');
    final secondClass = await createClass('Class B');
    final studentId = await createStudent(classId: firstClass);
    final current = await database.getCurrentStudentAssignment(studentId);

    expect(current, isNotNull);
    await expectLater(
      database.assignStudentToClass(
        studentId: studentId,
        classId: secondClass,
        effectiveFrom: current!.effectiveFrom,
      ),
      throwsStateError,
    );

    expect(await database.getStudentAssignmentHistory(studentId), hasLength(1));
  });

  test('rejects a batch that belongs to a different class', () async {
    final firstClass = await createClass('Class A');
    final secondClass = await createClass('Class B');
    final batchId = await database.saveBatch(
      classId: firstClass,
      name: 'Morning Batch',
    );
    final studentId = await createStudent();

    await expectLater(
      database.assignStudentToClass(
        studentId: studentId,
        classId: secondClass,
        batchId: batchId,
        effectiveFrom: DateTime.now(),
      ),
      throwsStateError,
    );
    expect(await database.getStudentAssignmentHistory(studentId), isEmpty);
  });

  test('clearing an assignment closes history and clears current class',
      () async {
    final classId = await createClass('Class A');
    final studentId = await createStudent(classId: classId);
    final current = await database.getCurrentStudentAssignment(studentId);

    await database.clearStudentAssignment(
      studentId: studentId,
      effectiveTo: current!.effectiveFrom.add(const Duration(days: 1)),
      reason: 'Student left institute',
    );

    expect(await database.getCurrentStudentAssignment(studentId), isNull);
    final history = await database.getStudentAssignmentHistory(studentId);
    expect(history, hasLength(1));
    expect(history.single.effectiveTo, isNotNull);
    expect((await database.getStudent(studentId))?.classId, isNull);
  });
}