import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:edumanage_offline/features/classes/presentation/class_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('class form validates required name and academic year', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ClassFormScreen()),
      ),
    );

    await tester.tap(find.text('Save class'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a class or batch name'), findsOneWidget);
    expect(find.text('Enter a valid academic year'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('class form prevents duplicate name in the same academic year', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await database.saveClass(
      name: 'Class 10 A',
      academicYear: '2026-2027',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: ClassFormScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Class 10 A');
    await tester.enterText(find.byType(TextFormField).at(1), '2026-2027');
    await tester.tap(find.text('Save class'));
    await tester.pumpAndSettle();

    expect(
      find.text('A class with this name already exists for this year'),
      findsOneWidget,
    );
    expect(await database.searchClasses('Class 10 A'), hasLength(1));

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
}
