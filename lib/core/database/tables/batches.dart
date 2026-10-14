import 'package:drift/drift.dart';

import 'classes.dart';

@DataClassName('ClassBatchSession')
class Batches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get classId => integer().references(Classes, #id, onDelete: KeyAction.restrict)();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get subject => text().nullable().withLength(min: 1, max: 80)();
  TextColumn get timing => text().nullable().withLength(min: 1, max: 100)();
  TextColumn get teacherName => text().nullable().withLength(min: 1, max: 120)();
  IntColumn get monthlyFeePaise => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {classId, name},
      ];
}
