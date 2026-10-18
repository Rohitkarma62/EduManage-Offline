import 'package:drift/native.dart';
import 'package:edumanage_offline/app/app.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dashboard opens backup and restore screen', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const EduManageApp(),
      ),
    );
    await tester.pumpAndSettle();

    final backupButton = find.text('Open backup & restore');
    await tester.ensureVisible(backupButton);
    await tester.pumpAndSettle();
    await tester.tap(backupButton);
    await tester.pumpAndSettle();

    expect(find.text('Backup & restore'), findsOneWidget);
    expect(find.text('Export backup'), findsOneWidget);
    expect(find.text('Choose backup to restore'), findsOneWidget);

    await database.close();
  });
}
