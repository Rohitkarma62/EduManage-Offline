import 'package:drift/drift.dart';

@DataClassName('Institute')
class Institutes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text().withLength(min: 1, max: 120)();

  TextColumn get academicYear => text().withLength(min: 4, max: 20)();

  TextColumn get phone => text().nullable().withLength(min: 7, max: 20)();

  TextColumn get currencyCode =>
      text().withDefault(const Constant('INR')).withLength(min: 3, max: 3)();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
