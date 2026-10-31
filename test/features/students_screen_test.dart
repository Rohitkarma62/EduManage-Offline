import 'package:drift/native.dart';
import 'package:edumanage_offline/app/app.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:edumanage_offline/features/students/presentation/student_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard opens student list and add form', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const EduManageApp(),
      ),
    );
    await tester.pumpAndSettle();

    final openStudentsButton = find.text('Open students');
    await tester.ensureVisible(openStudentsButton);
    await tester.pumpAndSettle();
    await tester.tap(openStudentsButton);
    await tester.pumpAndSettle();
    expect(find.text('Students'), findsOneWidget);
    expect(find.text('No students yet. Add the first student.'), findsOneWidget);

    await tester.tap(find.text('Add student'));
    await tester.pumpAndSettle();
    expect(find.text('Admission number *'), findsOneWidget);
    expect(find.text('Student name *'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('student form shows required-field validation', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: StudentFormScreen()),
      ),
    );

    await tester.tap(find.text('Save student'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an admission number'), findsOneWidget);
    expect(find.text('Enter the student name'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('student form reports duplicate admission number', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.saveStudent(
      admissionNumber: 'ADM-001',
      fullName: 'Existing Student',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: StudentFormScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), ' adm-001 ');
    await tester.enterText(find.byType(TextFormField).at(1), 'New Student');
    await tester.tap(find.text('Save student'));
    await tester.pumpAndSettle();

    expect(find.text('Admission number already exists'), findsOneWidget);
    expect(await database.searchStudents('ADM-001'), hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

}
