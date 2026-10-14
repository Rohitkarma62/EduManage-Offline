import 'package:drift/drift.dart';

import 'batches.dart';
import 'classes.dart';
import 'students.dart';

/// Effective-dated student class/batch placement history.
///
/// [effectiveTo] is exclusive. A null [effectiveTo] means the assignment is
/// current. Old rows are closed, never overwritten, when a student transfers.
@DataClassName('StudentAssignment')
class StudentAssignments extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get studentId => integer()
      .references(Students, #id, onDelete: KeyAction.restrict)();

  IntColumn get classId => integer()
      .references(Classes, #id, onDelete: KeyAction.restrict)();

  IntColumn get batchId => integer()
      .nullable()
      .references(Batches, #id, onDelete: KeyAction.restrict)();

  DateTimeColumn get effectiveFrom => dateTime()();
  DateTimeColumn get effectiveTo => dateTime().nullable()();
  TextColumn get transferReason =>
      text().nullable().withLength(min: 1, max: 240)();
  TextColumn get endReason =>
      text().nullable().withLength(min: 1, max: 240)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [];
}
