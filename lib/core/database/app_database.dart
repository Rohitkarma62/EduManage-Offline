import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/institutes.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Institutes])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'edumanage_offline'));

  @override
  int get schemaVersion => 1;
}
