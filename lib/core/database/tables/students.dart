import 'package:drift/drift.dart';

@DataClassName('Student')
class Students extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get admissionNumber =>
      text().withLength(min: 1, max: 40).unique()();
  TextColumn get fullName => text().withLength(min: 1, max: 120)();
  TextColumn get phone => text().nullable().withLength(min: 7, max: 20)();
  TextColumn get guardianName =>
      text().nullable().withLength(min: 1, max: 120)();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
