import 'package:edumanage_offline/app/app.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:edumanage_offline/core/database/database_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';

void main() {
  testWidgets('app opens dashboard and links to institute setup',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const EduManageApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('EduManage Offline'), findsOneWidget);
    expect(find.text('Institute dashboard'), findsOneWidget);
    expect(find.text('Set up institute'), findsOneWidget);

    await tester.tap(find.text('Set up institute'));
    await tester.pumpAndSettle();

    expect(find.text('Institute setup'), findsOneWidget);
    expect(find.text('Institute name *'), findsOneWidget);
    await database.close();
  });
}
