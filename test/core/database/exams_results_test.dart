import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late int classId;
  late int studentId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    classId = await database.saveClass(
      name: 'Class 10',
      academicYear: '2026-2027',
    );
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.customStatement('''
      INSERT INTO students
        (admission_number, full_name, class_id, is_active, created_at, updated_at)
      VALUES ('ADM-1001', 'Test Student', ?, 1, ?, ?)
    ''', [classId, now, now]);
    studentId = (await database.customSelect(
      "SELECT id FROM students WHERE admission_number = 'ADM-1001'",
    ).getSingle()).read<int>('id');
    await database.customStatement('''
      INSERT INTO student_assignments
        (student_id, class_id, batch_id, effective_from, effective_to,
         transfer_reason, end_reason, created_at)
      VALUES (?, ?, NULL, ?, NULL, 'Initial assignment', NULL, ?)
    ''', [studentId, classId, DateTime(2020).millisecondsSinceEpoch, now]);
  });

  tearDown(() async {
    await database.close();
  });

  test('creates an exam and saves a student result with summary', () async {
    final examId = await database.saveExam(
      classId: classId,
      title: 'Mid-term',
      subject: 'Mathematics',
      examDate: DateTime.now(),
      maxMarks: 100,
    );

    await database.saveExamResult(
      examId: examId,
      studentId: studentId,
      marksObtained: 82.5,
      remarks: 'Good work',
    );

    final exams = await database.getExams(classId: classId);
    final students = await database.getStudentsForExam(examId);
    final summary = await database.getExamSummary(examId);

    expect(exams, hasLength(1));
    expect(exams.single.read<String>('title'), 'Mid-term');
    expect(exams.single.read<int>('result_count'), 1);
    expect(students, hasLength(1));
    expect(students.single.read<double>('marks_obtained'), 82.5);
    expect(students.single.read<String>('remarks'), 'Good work');
    expect(summary['enteredCount'], 1);
    expect(summary['passCount'], 1);
    expect(summary['averageMarks'], 82.5);
  });

  test('rejects marks greater than the exam maximum', () async {
    final examId = await database.saveExam(
      classId: classId,
      title: 'Quiz',
      subject: 'Science',
      examDate: DateTime.now(),
      maxMarks: 20,
    );

    await expectLater(
      database.saveExamResult(
        examId: examId,
        studentId: studentId,
        marksObtained: 21,
      ),
      throwsArgumentError,
    );
    expect(await database.getStudentsForExam(examId), hasLength(1));
    expect((await database.getExamSummary(examId))['enteredCount'], 0);
  });

  test('prevents changing exam class or date after results are entered',
      () async {
    final examDate = DateTime(2026, 10, 10);
    final examId = await database.saveExam(
      classId: classId,
      title: 'Final Exam',
      subject: 'Mathematics',
      examDate: examDate,
      maxMarks: 100,
    );
    await database.saveExamResult(
      examId: examId,
      studentId: studentId,
      marksObtained: 75,
    );

    final otherClassId = await database.saveClass(
      name: 'Class 11',
      academicYear: '2026-2027',
    );

    await expectLater(
      database.saveExam(
        id: examId,
        classId: otherClassId,
        title: 'Final Exam',
        subject: 'Mathematics',
        examDate: examDate,
        maxMarks: 100,
      ),
      throwsStateError,
    );
    await expectLater(
      database.saveExam(
        id: examId,
        classId: classId,
        title: 'Final Exam',
        subject: 'Mathematics',
        examDate: examDate.add(const Duration(days: 1)),
        maxMarks: 100,
      ),
      throwsStateError,
    );

    final saved = await database.getExams(classId: classId);
    expect(saved, hasLength(1));
    expect(saved.single.read<int>('exam_date'),
        examDate.millisecondsSinceEpoch);
    expect(await database.getStudentsForExam(examId), hasLength(1));
    expect((await database.getExamSummary(examId))['enteredCount'], 1);
  });

  test('rejects invalid exam maximum marks', () async {
    await expectLater(
      database.saveExam(
        classId: classId,
        title: 'Quiz',
        subject: 'Science',
        examDate: DateTime.now(),
        maxMarks: 0,
      ),
      throwsArgumentError,
    );
  });
}
