import 'package:drift/native.dart';
import 'package:edumanage_offline/app/app.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard opens student list and add form', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(ProviderScope(overrides: [appDatabaseProvider.overrideWithValue(database)], child: const EduManageApp()));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open students'));
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
}
