import 'package:drift/drift.dart';

@DataClassName('ClassBatch')
class Classes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get academicYear => text().withLength(min: 4, max: 20)();
  TextColumn get description => text().nullable().withLength(min: 1, max: 240)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name, academicYear},
      ];
}
