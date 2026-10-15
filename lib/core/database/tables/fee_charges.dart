import 'package:drift/drift.dart';

import 'student_assignments.dart';
import 'students.dart';

/// A historical fee assessment. [periodEnd] is exclusive and money is in paise.
@DataClassName('FeeCharge')
class FeeCharges extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get studentId =>
      integer().references(Students, #id, onDelete: KeyAction.restrict)();

  IntColumn get assignmentId => integer()
      .references(StudentAssignments, #id, onDelete: KeyAction.restrict)();

  TextColumn get title => text().withLength(min: 1, max: 120)();
  IntColumn get amountPaise => integer()();
  DateTimeColumn get periodStart => dateTime()();
  DateTimeColumn get periodEnd => dateTime()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
