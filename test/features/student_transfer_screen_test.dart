import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:edumanage_offline/features/students/presentation/student_transfer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('transfer form requires a target class and a reason',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final classId = await database.saveClass(
      name: 'Class A',
      academicYear: '2026-2027',
    );
    final studentId = await database.saveStudent(
      admissionNumber: 'ADM-TRANSFER-1',
      fullName: 'Transfer Student',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: StudentTransferScreen(studentId: studentId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transfer student'), findsOneWidget);
    await tester.tap(find.text('New class *'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Class A • 2026-2027').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save transfer'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a transfer reason'), findsOneWidget);
    expect(await database.getStudentAssignmentHistory(studentId), isEmpty);
    expect(classId, greaterThan(0));

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
  testWidgets('transfer form rejects an unchanged class and batch',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final classId = await database.saveClass(
      name: 'Class A',
      academicYear: '2026-2027',
    );
    final studentId = await database.saveStudent(
      admissionNumber: 'ADM-TRANSFER-2',
      fullName: 'Already Assigned Student',
    );
    await database.assignStudentToClass(
      studentId: studentId,
      classId: classId,
      effectiveFrom: DateTime.now().subtract(const Duration(days: 2)),
      reason: 'Initial assignment',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: StudentTransferScreen(studentId: studentId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Transfer reason *'),
      'No actual placement change',
    );
    await tester.tap(find.text('Save transfer'));
    await tester.pumpAndSettle();

    expect(
      find.text('Choose a different class or batch before saving a transfer.'),
      findsOneWidget,
    );
    expect(await database.getStudentAssignmentHistory(studentId), hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('same-day assignment explains why transfer date is unavailable',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final classId = await database.saveClass(
      name: 'Class A',
      academicYear: '2026-2027',
    );
    final studentId = await database.saveStudent(
      admissionNumber: 'ADM-TRANSFER-3',
      fullName: 'Newly Assigned Student',
    );
    await database.assignStudentToClass(
      studentId: studentId,
      classId: classId,
      effectiveFrom: DateTime.now(),
      reason: 'Initial assignment',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          home: StudentTransferScreen(studentId: studentId),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'This student’s current assignment started today. Transfers can be scheduled from tomorrow; come back then.',
      ),
      findsOneWidget,
    );
    expect(find.text('Save transfer'), findsOneWidget);
    expect(tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

}
