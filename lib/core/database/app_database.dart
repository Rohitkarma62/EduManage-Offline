import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/fee_charges.dart';
import 'tables/batches.dart';
import 'tables/classes.dart';
import 'tables/institutes.dart';
import 'tables/students.dart';
import 'tables/student_assignments.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Institutes,
  Classes,
  Students,
  Batches,
  StudentAssignments,
  FeeCharges
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'edumanage_offline'));

  @override
  int get schemaVersion => 14;

  Future<void> _installStaffSalaryPaymentsTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS staff_salary_payments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        staff_id INTEGER NOT NULL REFERENCES staff(id) ON DELETE RESTRICT,
        amount_paise INTEGER NOT NULL CHECK (amount_paise > 0),
        payment_method TEXT NOT NULL CHECK (payment_method IN ('Cash', 'Bank transfer', 'UPI', 'Cheque', 'Other')),
        reference TEXT,
        notes TEXT,
        paid_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS staff_salary_payments_staff_date
      ON staff_salary_payments(staff_id, paid_at DESC, id DESC)
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS staff_salary_payment_positive_insert
      BEFORE INSERT ON staff_salary_payments
      WHEN NEW.amount_paise <= 0
      BEGIN SELECT RAISE(ABORT, 'salary payment must be positive'); END
    ''');
  }

  Future<List<QueryRow>> getStaffSalaryPayments({int? staffId}) {
    return customSelect('''
      SELECT p.id, p.staff_id, s.full_name AS staff_name, s.monthly_salary_paise,
             p.amount_paise, p.payment_method, p.reference, p.notes, p.paid_at, p.created_at
      FROM staff_salary_payments p
      JOIN staff s ON s.id = p.staff_id
      ${staffId == null ? '' : 'WHERE p.staff_id = ?'}
      ORDER BY p.paid_at DESC, p.id DESC
    ''', variables: staffId == null ? const [] : [Variable.withInt(staffId)])
        .get();
  }

  Future<int> recordStaffSalaryPayment({
    required int staffId,
    required int amountPaise,
    required String paymentMethod,
    required DateTime paidAt,
    String? reference,
    String? notes,
  }) async {
    if (amountPaise <= 0) {
      throw ArgumentError.value(
          amountPaise, 'amountPaise', 'Must be greater than zero');
    }
    const methods = {'Cash', 'Bank transfer', 'UPI', 'Cheque', 'Other'};
    if (!methods.contains(paymentMethod)) {
      throw ArgumentError.value(
          paymentMethod, 'paymentMethod', 'Unsupported payment method');
    }
    if (paidAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      throw ArgumentError.value(
          paidAt, 'paidAt', 'Payment date cannot be in the future');
    }
    final staff = await customSelect(
      'SELECT id FROM staff WHERE id = ? AND is_active = 1',
      variables: [Variable.withInt(staffId)],
    ).get();
    if (staff.isEmpty) throw StateError('Active staff member does not exist');
    final normalizedReference = reference?.trim();
    final normalizedNotes = notes?.trim();
    if ((normalizedReference?.length ?? 0) > 120) {
      throw ArgumentError('Reference must be 120 characters or fewer');
    }
    if ((normalizedNotes?.length ?? 0) > 500) {
      throw ArgumentError('Notes must be 500 characters or fewer');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement('''
      INSERT INTO staff_salary_payments
        (staff_id, amount_paise, payment_method, reference, notes, paid_at, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      staffId,
      amountPaise,
      paymentMethod,
      normalizedReference?.isEmpty == true ? null : normalizedReference,
      normalizedNotes?.isEmpty == true ? null : normalizedNotes,
      paidAt.millisecondsSinceEpoch,
      now,
    ]);
    final row =
        await customSelect('SELECT last_insert_rowid() AS id').getSingle();
    return row.read<int>('id');
  }

  Future<Map<String, int>> getStaffSalarySummary({
    required int staffId,
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final row = await customSelect('''
      SELECT s.monthly_salary_paise AS expected,
             COALESCE(SUM(CASE WHEN p.paid_at >= ? AND p.paid_at < ? THEN p.amount_paise ELSE 0 END), 0) AS paid
      FROM staff s LEFT JOIN staff_salary_payments p ON p.staff_id = s.id
      WHERE s.id = ?
      GROUP BY s.id
    ''', variables: [
      Variable.withInt(start.millisecondsSinceEpoch),
      Variable.withInt(end.millisecondsSinceEpoch),
      Variable.withInt(staffId),
    ]).getSingleOrNull();
    if (row == null) throw StateError('Staff member does not exist');
    final expected = row.read<int>('expected');
    final paid = row.read<int>('paid');
    return {
      'expectedPaise': expected,
      'paidPaise': paid,
      'pendingPaise': (expected - paid).clamp(0, expected).toInt()
    };
  }

  Future<void> _installExpensesTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL CHECK (length(trim(category)) BETWEEN 1 AND 80),
        description TEXT NOT NULL CHECK (length(trim(description)) BETWEEN 1 AND 240),
        amount_paise INTEGER NOT NULL CHECK (amount_paise > 0),
        payment_method TEXT NOT NULL CHECK (payment_method IN ('Cash', 'Bank transfer', 'UPI', 'Cheque', 'Other')),
        reference TEXT,
        spent_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS expenses_spent_at
      ON expenses(spent_at DESC, id DESC)
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS expenses_category_date
      ON expenses(category, spent_at DESC)
    ''');
  }

  Future<int> recordExpense({
    required String category,
    required String description,
    required int amountPaise,
    required String paymentMethod,
    required DateTime spentAt,
    String? reference,
  }) async {
    final normalizedCategory = category.trim();
    final normalizedDescription = description.trim();
    final normalizedReference = reference?.trim();
    if (normalizedCategory.isEmpty || normalizedCategory.length > 80) {
      throw ArgumentError.value(
          category, 'category', 'Must be 1 to 80 characters');
    }
    if (normalizedDescription.isEmpty || normalizedDescription.length > 240) {
      throw ArgumentError.value(
          description, 'description', 'Must be 1 to 240 characters');
    }
    if (amountPaise <= 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise', 'Must be positive');
    }
    const methods = {'Cash', 'Bank transfer', 'UPI', 'Cheque', 'Other'};
    if (!methods.contains(paymentMethod)) {
      throw ArgumentError.value(
          paymentMethod, 'paymentMethod', 'Unsupported payment method');
    }
    if (spentAt.isAfter(DateTime.now().add(const Duration(minutes: 1)))) {
      throw ArgumentError.value(
          spentAt, 'spentAt', 'Expense date cannot be in the future');
    }
    if ((normalizedReference?.length ?? 0) > 120) {
      throw ArgumentError.value(
          reference, 'reference', 'Must be at most 120 characters');
    }
    await customStatement('''
      INSERT INTO expenses
        (category, description, amount_paise, payment_method, reference, spent_at, created_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', [
      normalizedCategory,
      normalizedDescription,
      amountPaise,
      paymentMethod,
      normalizedReference == null || normalizedReference.isEmpty
          ? null
          : normalizedReference,
      spentAt.millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    ]);
    final row =
        await customSelect('SELECT last_insert_rowid() AS id').getSingle();
    return row.read<int>('id');
  }

  Future<List<QueryRow>> getExpenses(
      {String? category, DateTime? month}) async {
    final clauses = <String>[];
    final variables = <Variable<Object>>[];
    if (category != null && category.trim().isNotEmpty) {
      clauses.add('category = ?');
      variables.add(Variable.withString(category.trim()));
    }
    if (month != null) {
      final start = DateTime(month.year, month.month);
      final end = DateTime(month.year, month.month + 1);
      clauses.add('spent_at >= ? AND spent_at < ?');
      variables.add(Variable.withInt(start.millisecondsSinceEpoch));
      variables.add(Variable.withInt(end.millisecondsSinceEpoch));
    }
    return customSelect('''
      SELECT id, category, description, amount_paise, payment_method, reference, spent_at, created_at
      FROM expenses
      ${clauses.isEmpty ? '' : 'WHERE ${clauses.join(' AND ')}'}
      ORDER BY spent_at DESC, id DESC
    ''', variables: variables).get();
  }

  Future<Map<String, int>> getExpenseSummary({required DateTime month}) async {
    final start = DateTime(month.year, month.month);
    final end = DateTime(month.year, month.month + 1);
    final row = await customSelect('''
      SELECT COUNT(*) AS count, COALESCE(SUM(amount_paise), 0) AS total
      FROM expenses WHERE spent_at >= ? AND spent_at < ?
    ''', variables: [
      Variable.withInt(start.millisecondsSinceEpoch),
      Variable.withInt(end.millisecondsSinceEpoch),
    ]).getSingle();
    return {
      'count': row.read<int>('count'),
      'totalPaise': row.read<int>('total')
    };
  }

  Future<void> _installFeeChargeGuards() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_charges_positive_amount_insert
      BEFORE INSERT ON fee_charges
      WHEN NEW.amount_paise <= 0
      BEGIN SELECT RAISE(ABORT, 'fee charge amount must be positive'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_charges_positive_amount_update
      BEFORE UPDATE OF amount_paise ON fee_charges
      WHEN NEW.amount_paise <= 0
      BEGIN SELECT RAISE(ABORT, 'fee charge amount must be positive'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_charges_valid_period_insert
      BEFORE INSERT ON fee_charges
      WHEN NEW.period_end <= NEW.period_start
      BEGIN SELECT RAISE(ABORT, 'fee charge period end must be after start'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_charges_valid_period_update
      BEFORE UPDATE OF period_start, period_end ON fee_charges
      WHEN NEW.period_end <= NEW.period_start
      BEGIN SELECT RAISE(ABORT, 'fee charge period end must be after start'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_charges_assignment_student_insert
      BEFORE INSERT ON fee_charges
      WHEN NOT EXISTS (
        SELECT 1 FROM student_assignments a
        WHERE a.id = NEW.assignment_id AND a.student_id = NEW.student_id
      )
      BEGIN SELECT RAISE(ABORT, 'fee charge assignment must belong to student'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_charges_assignment_student_update
      BEFORE UPDATE OF assignment_id, student_id ON fee_charges
      WHEN NOT EXISTS (
        SELECT 1 FROM student_assignments a
        WHERE a.id = NEW.assignment_id AND a.student_id = NEW.student_id
      )
      BEGIN SELECT RAISE(ABORT, 'fee charge assignment must belong to student'); END
    ''');
  }

  Future<void> _installBatchFeeGuards() async {
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS batches_fee_nonnegative_insert
      BEFORE INSERT ON batches
      WHEN NEW.monthly_fee_paise IS NOT NULL AND NEW.monthly_fee_paise < 0
      BEGIN
        SELECT RAISE(ABORT, 'monthly_fee_paise must be non-negative');
      END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS batches_fee_nonnegative_update
      BEFORE UPDATE OF monthly_fee_paise ON batches
      WHEN NEW.monthly_fee_paise IS NOT NULL AND NEW.monthly_fee_paise < 0
      BEGIN
        SELECT RAISE(ABORT, 'monthly_fee_paise must be non-negative');
      END
    ''');
  }

  Future<void> _installIntegrityGuards() async {
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS classes_normalized_duplicate_insert
      BEFORE INSERT ON classes
      WHEN EXISTS (
        SELECT 1 FROM classes c
        WHERE lower(trim(c.name)) = lower(trim(NEW.name))
          AND lower(trim(c.academic_year)) = lower(trim(NEW.academic_year))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate class name for academic year'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS classes_normalized_duplicate_update
      BEFORE UPDATE OF name, academic_year ON classes
      WHEN EXISTS (
        SELECT 1 FROM classes c
        WHERE c.id != NEW.id
          AND lower(trim(c.name)) = lower(trim(NEW.name))
          AND lower(trim(c.academic_year)) = lower(trim(NEW.academic_year))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate class name for academic year'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_normalized_duplicate_insert
      BEFORE INSERT ON batches
      WHEN EXISTS (
        SELECT 1 FROM batches b
        WHERE b.class_id = NEW.class_id
          AND lower(trim(b.name)) = lower(trim(NEW.name))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate batch name for class'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_normalized_duplicate_update
      BEFORE UPDATE OF class_id, name ON batches
      WHEN EXISTS (
        SELECT 1 FROM batches b
        WHERE b.id != NEW.id
          AND b.class_id = NEW.class_id
          AND lower(trim(b.name)) = lower(trim(NEW.name))
      )
      BEGIN SELECT RAISE(ABORT, 'duplicate batch name for class'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_parent_class_insert
      BEFORE INSERT ON batches
      WHEN NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'batch parent class does not exist'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS batches_parent_class_update
      BEFORE UPDATE OF class_id ON batches
      WHEN NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'batch parent class does not exist'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS students_class_reference_insert
      BEFORE INSERT ON students
      WHEN NEW.class_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'student class does not exist'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS students_class_reference_update
      BEFORE UPDATE OF class_id ON students
      WHEN NEW.class_id IS NOT NULL
        AND NOT EXISTS (SELECT 1 FROM classes c WHERE c.id = NEW.class_id)
      BEGIN SELECT RAISE(ABORT, 'student class does not exist'); END
    """);
  }

  Future<void> _installAssignmentGuards() async {
    await customStatement('''
      CREATE UNIQUE INDEX IF NOT EXISTS student_assignments_one_current
      ON student_assignments(student_id) WHERE effective_to IS NULL
    ''');
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_valid_dates_insert
      BEFORE INSERT ON student_assignments
      WHEN NEW.effective_to IS NOT NULL AND NEW.effective_to <= NEW.effective_from
      BEGIN SELECT RAISE(ABORT, 'assignment end must be after start'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_valid_dates_update
      BEFORE UPDATE OF effective_from, effective_to ON student_assignments
      WHEN NEW.effective_to IS NOT NULL AND NEW.effective_to <= NEW.effective_from
      BEGIN SELECT RAISE(ABORT, 'assignment end must be after start'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_batch_class_insert
      BEFORE INSERT ON student_assignments
      WHEN NEW.batch_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM batches b
        WHERE b.id = NEW.batch_id AND b.class_id = NEW.class_id
      )
      BEGIN SELECT RAISE(ABORT, 'assigned batch must belong to assigned class'); END
    """);
    await customStatement("""
      CREATE TRIGGER IF NOT EXISTS student_assignments_batch_class_update
      BEFORE UPDATE OF batch_id, class_id ON student_assignments
      WHEN NEW.batch_id IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM batches b
        WHERE b.id = NEW.batch_id AND b.class_id = NEW.class_id
      )
      BEGIN SELECT RAISE(ABORT, 'assigned batch must belong to assigned class'); END
    """);
  }

  Future<void> _installFeePaymentTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS fee_payments (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        fee_charge_id INTEGER NOT NULL
          REFERENCES fee_charges(id) ON DELETE RESTRICT,
        amount_paise INTEGER NOT NULL CHECK (amount_paise > 0),
        method TEXT NOT NULL CHECK (
          method IN ('cash', 'upi', 'bank_transfer', 'card', 'cheque', 'other')
        ),
        reference TEXT,
        idempotency_key TEXT NOT NULL UNIQUE
          CHECK (length(trim(idempotency_key)) BETWEEN 1 AND 120),
        received_at INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
    // Enforce the relationship explicitly because some SQLite executors used
    // by the app and tests do not enable PRAGMA foreign_keys.
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_payments_charge_exists_insert
      BEFORE INSERT ON fee_payments
      WHEN NOT EXISTS (
        SELECT 1 FROM fee_charges c WHERE c.id = NEW.fee_charge_id
      )
      BEGIN SELECT RAISE(ABORT, 'payment fee charge does not exist'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS fee_payments_charge_exists_update
      BEFORE UPDATE OF fee_charge_id ON fee_payments
      WHEN NOT EXISTS (
        SELECT 1 FROM fee_charges c WHERE c.id = NEW.fee_charge_id
      )
      BEGIN SELECT RAISE(ABORT, 'payment fee charge does not exist'); END
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS fee_payments_charge_received
      ON fee_payments(fee_charge_id, received_at DESC, id DESC)
    ''');
  }

  Future<void> _installStaffTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS staff (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        full_name TEXT NOT NULL CHECK (length(trim(full_name)) BETWEEN 1 AND 100),
        role TEXT NOT NULL CHECK (length(trim(role)) BETWEEN 1 AND 80),
        phone TEXT,
        email TEXT,
        monthly_salary_paise INTEGER NOT NULL DEFAULT 0 CHECK (monthly_salary_paise >= 0),
        is_active INTEGER NOT NULL DEFAULT 1 CHECK (is_active IN (0, 1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS staff_active_name
      ON staff(is_active, full_name COLLATE NOCASE)
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS staff_valid_insert
      BEFORE INSERT ON staff
      WHEN length(trim(NEW.full_name)) NOT BETWEEN 1 AND 100
        OR length(trim(NEW.role)) NOT BETWEEN 1 AND 80
        OR NEW.monthly_salary_paise < 0
      BEGIN SELECT RAISE(ABORT, 'invalid staff details'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS staff_valid_update
      BEFORE UPDATE OF full_name, role, monthly_salary_paise ON staff
      WHEN length(trim(NEW.full_name)) NOT BETWEEN 1 AND 100
        OR length(trim(NEW.role)) NOT BETWEEN 1 AND 80
        OR NEW.monthly_salary_paise < 0
      BEGIN SELECT RAISE(ABORT, 'invalid staff details'); END
    ''');
  }

  Future<List<QueryRow>> getStaffRecords({bool includeInactive = false}) {
    return customSelect('''
      SELECT id, full_name, role, phone, email, monthly_salary_paise,
             is_active, created_at, updated_at
      FROM staff
      ${includeInactive ? '' : 'WHERE is_active = 1'}
      ORDER BY is_active DESC, full_name COLLATE NOCASE, id
    ''').get();
  }

  Future<int> saveStaff({
    int? id,
    required String fullName,
    required String role,
    String? phone,
    String? email,
    int monthlySalaryPaise = 0,
  }) async {
    final name = fullName.trim();
    final normalizedRole = role.trim();
    final normalizedPhone = phone?.trim();
    final normalizedEmail = email?.trim();
    if (name.isEmpty || name.length > 100) {
      throw ArgumentError.value(
          fullName, 'fullName', 'Must be 1 to 100 characters');
    }
    if (normalizedRole.isEmpty || normalizedRole.length > 80) {
      throw ArgumentError.value(role, 'role', 'Must be 1 to 80 characters');
    }
    if (normalizedPhone != null &&
        normalizedPhone.isNotEmpty &&
        normalizedPhone.length > 30) {
      throw ArgumentError.value(
          phone, 'phone', 'Must be at most 30 characters');
    }
    if (normalizedEmail != null &&
        normalizedEmail.isNotEmpty &&
        normalizedEmail.length > 120) {
      throw ArgumentError.value(
          email, 'email', 'Must be at most 120 characters');
    }
    if (monthlySalaryPaise < 0) {
      throw ArgumentError.value(
          monthlySalaryPaise, 'monthlySalaryPaise', 'Must be non-negative');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    if (id == null) {
      await customStatement('''
        INSERT INTO staff
          (full_name, role, phone, email, monthly_salary_paise, is_active, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, 1, ?, ?)
      ''', [
        name,
        normalizedRole,
        normalizedPhone == null || normalizedPhone.isEmpty
            ? null
            : normalizedPhone,
        normalizedEmail == null || normalizedEmail.isEmpty
            ? null
            : normalizedEmail,
        monthlySalaryPaise,
        now,
        now,
      ]);
      final row =
          await customSelect('SELECT last_insert_rowid() AS id').getSingle();
      return row.read<int>('id');
    }
    final existing = await customSelect(
      'SELECT id FROM staff WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).get();
    if (existing.isEmpty) throw StateError('Staff record does not exist');
    await customStatement('''
      UPDATE staff SET full_name = ?, role = ?, phone = ?, email = ?,
        monthly_salary_paise = ?, updated_at = ? WHERE id = ?
    ''', [
      name,
      normalizedRole,
      normalizedPhone == null || normalizedPhone.isEmpty
          ? null
          : normalizedPhone,
      normalizedEmail == null || normalizedEmail.isEmpty
          ? null
          : normalizedEmail,
      monthlySalaryPaise,
      now,
      id,
    ]);
    return id;
  }

  Future<void> setStaffActive(int id, {required bool isActive}) async {
    await customStatement(
      'UPDATE staff SET is_active = ?, updated_at = ? WHERE id = ?',
      [isActive ? 1 : 0, DateTime.now().millisecondsSinceEpoch, id],
    );
  }

  Future<void> _installAttendanceTable() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS attendance_records (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
        attendance_date TEXT NOT NULL CHECK (
          length(attendance_date) = 10
          AND attendance_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
        ),
        status TEXT NOT NULL CHECK (status IN ('present', 'absent', 'leave')),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(student_id, attendance_date)
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS attendance_records_date_status
      ON attendance_records(attendance_date, status, student_id)
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS attendance_student_exists_insert
      BEFORE INSERT ON attendance_records
      WHEN NOT EXISTS (SELECT 1 FROM students s WHERE s.id = NEW.student_id)
      BEGIN SELECT RAISE(ABORT, 'attendance student does not exist'); END
    ''');
  }

  String _attendanceDateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<List<QueryRow>> getAttendanceForDate(DateTime date) {
    final key = _attendanceDateKey(date);
    return customSelect('''
      SELECT s.id AS student_id, s.full_name AS full_name,
             s.admission_number AS admission_number,
             ar.status AS attendance_status
      FROM students s
      LEFT JOIN attendance_records ar
        ON ar.student_id = s.id AND ar.attendance_date = ?
      WHERE s.is_active = 1
      ORDER BY s.full_name COLLATE NOCASE, s.id
    ''', variables: [Variable.withString(key)]).get();
  }

  Future<void> saveAttendanceForDate(
    DateTime date,
    Map<int, String> statuses,
  ) async {
    const allowed = {'present', 'absent', 'leave'};
    if (statuses.values.any((status) => !allowed.contains(status))) {
      throw ArgumentError(
          'Attendance status must be present, absent, or leave.');
    }
    final dateKey = _attendanceDateKey(date);
    final now = DateTime.now().millisecondsSinceEpoch;
    await transaction(() async {
      for (final entry in statuses.entries) {
        await customStatement('''
          INSERT INTO attendance_records
            (student_id, attendance_date, status, created_at, updated_at)
          VALUES (?, ?, ?, ?, ?)
          ON CONFLICT(student_id, attendance_date) DO UPDATE SET
            status = excluded.status, updated_at = excluded.updated_at
        ''', [entry.key, dateKey, entry.value, now, now]);
      }
    });
  }

  Future<Map<String, int>> getAttendanceSummary(DateTime date) async {
    final key = _attendanceDateKey(date);
    final row = await customSelect('''
      SELECT
        SUM(CASE WHEN ar.status = 'present' THEN 1 ELSE 0 END) AS present_count,
        SUM(CASE WHEN ar.status = 'absent' THEN 1 ELSE 0 END) AS absent_count,
        SUM(CASE WHEN ar.status = 'leave' THEN 1 ELSE 0 END) AS leave_count,
        SUM(CASE WHEN ar.status IS NULL THEN 1 ELSE 0 END) AS unmarked_count
      FROM students s
      LEFT JOIN attendance_records ar
        ON ar.student_id = s.id AND ar.attendance_date = ?
      WHERE s.is_active = 1
    ''', variables: [Variable.withString(key)]).getSingle();
    return {
      'present': row.read<int?>('present_count') ?? 0,
      'absent': row.read<int?>('absent_count') ?? 0,
      'leave': row.read<int?>('leave_count') ?? 0,
      'unmarked': row.read<int?>('unmarked_count') ?? 0,
    };
  }

  Future<void> _installExamsTables() async {
    await customStatement('''
      CREATE TABLE IF NOT EXISTS exams (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        class_id INTEGER NOT NULL REFERENCES classes(id) ON DELETE RESTRICT,
        title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 120),
        subject TEXT NOT NULL CHECK (length(trim(subject)) BETWEEN 1 AND 80),
        exam_date INTEGER NOT NULL,
        max_marks INTEGER NOT NULL CHECK (max_marks > 0 AND max_marks <= 100000),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS exams_class_date
      ON exams(class_id, exam_date DESC, id DESC)
    ''');
    await customStatement('''
      CREATE TABLE IF NOT EXISTS exam_results (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        exam_id INTEGER NOT NULL REFERENCES exams(id) ON DELETE RESTRICT,
        student_id INTEGER NOT NULL REFERENCES students(id) ON DELETE RESTRICT,
        marks_obtained REAL NOT NULL CHECK (marks_obtained >= 0),
        remarks TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(exam_id, student_id)
      )
    ''');
    await customStatement('''
      CREATE INDEX IF NOT EXISTS exam_results_exam_student
      ON exam_results(exam_id, student_id)
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS exam_result_valid_insert
      BEFORE INSERT ON exam_results
      WHEN NEW.marks_obtained < 0 OR NEW.marks_obtained > (
        SELECT max_marks FROM exams WHERE id = NEW.exam_id
      )
      BEGIN SELECT RAISE(ABORT, 'marks must be between zero and exam maximum'); END
    ''');
    await customStatement('''
      CREATE TRIGGER IF NOT EXISTS exam_result_valid_update
      BEFORE UPDATE OF exam_id, marks_obtained ON exam_results
      WHEN NEW.marks_obtained < 0 OR NEW.marks_obtained > (
        SELECT max_marks FROM exams WHERE id = NEW.exam_id
      )
      BEGIN SELECT RAISE(ABORT, 'marks must be between zero and exam maximum'); END
    ''');
  }

  Future<int> saveExam({
    int? id,
    required int classId,
    required String title,
    required String subject,
    required DateTime examDate,
    required int maxMarks,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedSubject = subject.trim();
    if (normalizedTitle.isEmpty || normalizedTitle.length > 120) {
      throw ArgumentError.value(title, 'title', 'Must be 1 to 120 characters');
    }
    if (normalizedSubject.isEmpty || normalizedSubject.length > 80) {
      throw ArgumentError.value(subject, 'subject', 'Must be 1 to 80 characters');
    }
    if (maxMarks <= 0 || maxMarks > 100000) {
      throw ArgumentError.value(maxMarks, 'maxMarks', 'Must be between 1 and 100000');
    }
    final classRow = await customSelect(
      'SELECT id FROM classes WHERE id = ?',
      variables: [Variable.withInt(classId)],
    ).getSingleOrNull();
    if (classRow == null) {
      throw StateError('Class does not exist');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    if (id == null) {
      await customStatement('''
        INSERT INTO exams (class_id, title, subject, exam_date, max_marks, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      ''', [classId, normalizedTitle, normalizedSubject, examDate.millisecondsSinceEpoch, maxMarks, now, now]);
      final row = await customSelect('SELECT last_insert_rowid() AS id').getSingle();
      return row.read<int>('id');
    }
    final existing = await customSelect(
      'SELECT id FROM exams WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).getSingleOrNull();
    if (existing == null) {
      throw StateError('Exam does not exist');
    }
    final recorded = await customSelect(
      'SELECT COUNT(*) AS total FROM exam_results WHERE exam_id = ?',
      variables: [Variable.withInt(id)],
    ).getSingle();
    if (recorded.read<int>('total') > 0 && maxMarks != (await customSelect(
      'SELECT max_marks FROM exams WHERE id = ?',
      variables: [Variable.withInt(id)],
    ).getSingle()).read<int>('max_marks')) {
      throw StateError('Maximum marks cannot change after results are entered');
    }
    await customStatement('''
      UPDATE exams SET class_id = ?, title = ?, subject = ?, exam_date = ?,
        max_marks = ?, updated_at = ? WHERE id = ?
    ''', [classId, normalizedTitle, normalizedSubject, examDate.millisecondsSinceEpoch, maxMarks, now, id]);
    return id;
  }

  Future<List<QueryRow>> getExams({int? classId}) {
    return customSelect('''
      SELECT e.id, e.class_id, c.name AS class_name, e.title, e.subject,
             e.exam_date, e.max_marks, e.created_at, e.updated_at,
             (SELECT COUNT(*) FROM exam_results r WHERE r.exam_id = e.id) AS result_count
      FROM exams e JOIN classes c ON c.id = e.class_id
      ${classId == null ? '' : 'WHERE e.class_id = ?'}
      ORDER BY e.exam_date DESC, e.id DESC
    ''', variables: classId == null ? const [] : [Variable.withInt(classId)]).get();
  }

  Future<List<QueryRow>> getStudentsForExam(int examId) async {
    final exam = await customSelect(
      'SELECT class_id, exam_date FROM exams WHERE id = ?',
      variables: [Variable.withInt(examId)],
    ).getSingleOrNull();
    if (exam == null) {
      throw StateError('Exam does not exist');
    }
    final classId = exam.read<int>('class_id');
    final examDate = exam.read<int>('exam_date');
    return customSelect('''
      SELECT s.id AS student_id, s.full_name, s.admission_number,
             r.marks_obtained, r.remarks, r.id AS result_id
      FROM student_assignments a
      JOIN students s ON s.id = a.student_id
      LEFT JOIN exam_results r ON r.exam_id = ? AND r.student_id = s.id
      WHERE a.class_id = ?
        AND a.effective_from <= ?
        AND (a.effective_to IS NULL OR a.effective_to > ?)
      GROUP BY s.id
      ORDER BY s.full_name COLLATE NOCASE, s.id
    ''', variables: [
      Variable.withInt(examId),
      Variable.withInt(classId),
      Variable.withInt(examDate),
      Variable.withInt(examDate),
    ]).get();
  }

  Future<int> saveExamResult({
    required int examId,
    required int studentId,
    required double marksObtained,
    String? remarks,
  }) async {
    if (!marksObtained.isFinite || marksObtained < 0) {
      throw ArgumentError.value(marksObtained, 'marksObtained', 'Must be a finite non-negative value');
    }
    final normalizedRemarks = remarks?.trim();
    if ((normalizedRemarks?.length ?? 0) > 240) {
      throw ArgumentError.value(remarks, 'remarks', 'Must be at most 240 characters');
    }
    final exam = await customSelect(
      'SELECT class_id, exam_date, max_marks FROM exams WHERE id = ?',
      variables: [Variable.withInt(examId)],
    ).getSingleOrNull();
    if (exam == null) throw StateError('Exam does not exist');
    if (marksObtained > exam.read<int>('max_marks')) {
      throw ArgumentError.value(marksObtained, 'marksObtained', 'Cannot exceed maximum marks');
    }
    final examDate = exam.read<int>('exam_date');
    final assignment = await customSelect('''
      SELECT id FROM student_assignments
      WHERE student_id = ? AND class_id = ? AND effective_from <= ?
        AND (effective_to IS NULL OR effective_to > ?)
      LIMIT 1
    ''', variables: [
      Variable.withInt(studentId),
      Variable.withInt(exam.read<int>('class_id')),
      Variable.withInt(examDate),
      Variable.withInt(examDate),
    ]).getSingleOrNull();
    if (assignment == null) {
      throw StateError('Student was not assigned to this class on the exam date');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await customStatement('''
      INSERT INTO exam_results (exam_id, student_id, marks_obtained, remarks, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?)
      ON CONFLICT(exam_id, student_id) DO UPDATE SET
        marks_obtained = excluded.marks_obtained,
        remarks = excluded.remarks,
        updated_at = excluded.updated_at
    ''', [
      examId, studentId, marksObtained,
      normalizedRemarks == null || normalizedRemarks.isEmpty ? null : normalizedRemarks,
      now, now,
    ]);
    final row = await customSelect(
      'SELECT id FROM exam_results WHERE exam_id = ? AND student_id = ?',
      variables: [Variable.withInt(examId), Variable.withInt(studentId)],
    ).getSingle();
    return row.read<int>('id');
  }

  Future<Map<String, num>> getExamSummary(int examId) async {
    final row = await customSelect('''
      SELECT e.max_marks, COUNT(r.id) AS entered_count,
             COALESCE(AVG(r.marks_obtained), 0) AS average_marks,
             COALESCE(SUM(CASE WHEN r.marks_obtained >= e.max_marks * 0.35 THEN 1 ELSE 0 END), 0) AS pass_count
      FROM exams e LEFT JOIN exam_results r ON r.exam_id = e.id
      WHERE e.id = ? GROUP BY e.id
    ''', variables: [Variable.withInt(examId)]).getSingleOrNull();
    if (row == null) {
      throw StateError('Exam does not exist');
    }
    return {
      'maxMarks': row.read<int>('max_marks'),
      'enteredCount': row.read<int>('entered_count'),
      'averageMarks': row.read<double>('average_marks'),
      'passCount': row.read<int>('pass_count'),
    };
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _installBatchFeeGuards();
          await _installIntegrityGuards();
          await _installAssignmentGuards();
          await _installFeeChargeGuards();
          await _installFeePaymentTable();
          await _installAttendanceTable();
          await _installStaffTable();
          await _installStaffSalaryPaymentsTable();
          await _installExpensesTable();
          await _installExamsTables();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(students);
          if (from < 3) {
            await m.createTable(classes);
            await m.addColumn(students, students.classId);
          }
          if (from < 4) await m.createTable(batches);
          if (from < 5) await _installBatchFeeGuards();
          if (from < 6) await _installIntegrityGuards();
          if (from < 7) {
            await m.createTable(studentAssignments);
            await customStatement('''
              INSERT INTO student_assignments
                (student_id, class_id, batch_id, effective_from, effective_to, transfer_reason, created_at)
              SELECT id, class_id, NULL, created_at, NULL, 'Migrated existing class assignment', created_at
              FROM students
              WHERE class_id IS NOT NULL
            ''');
            await _installAssignmentGuards();
          }
          if (from < 8) {
            await m.createTable(feeCharges);
            await _installFeeChargeGuards();
          }
          if (from < 9) await _installFeePaymentTable();
          if (from < 10) await _installAttendanceTable();
          if (from < 11) await _installStaffTable();
          if (from < 12) await _installStaffSalaryPaymentsTable();
          if (from < 13) await _installExpensesTable();
          if (from < 14) await _installExamsTables();
        },
      );

  /// Creates a fee charge tied to the student's historical assignment.
  /// Period end is exclusive; amounts are stored as integer paise.
  Future<int> createFeeCharge({
    required int studentId,
    required int assignmentId,
    required String title,
    required int amountPaise,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime dueDate,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty || normalizedTitle.length > 120) {
      throw ArgumentError.value(title, 'title', 'Must be 1 to 120 characters');
    }
    if (amountPaise <= 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise', 'Must be positive');
    }
    if (!periodEnd.isAfter(periodStart)) {
      throw ArgumentError('Fee period end must be after period start');
    }
    return into(feeCharges).insert(FeeChargesCompanion.insert(
      studentId: studentId,
      assignmentId: assignmentId,
      title: normalizedTitle,
      amountPaise: amountPaise,
      periodStart: periodStart,
      periodEnd: periodEnd,
      dueDate: dueDate,
    ));
  }

  Future<List<FeeCharge>> getFeeChargesForStudent(int studentId) =>
      (select(feeCharges)
            ..where((row) => row.studentId.equals(studentId))
            ..orderBy([
              (row) => OrderingTerm.desc(row.periodStart),
              (row) => OrderingTerm.desc(row.id),
            ]))
          .get();

  /// Records a payment once per idempotency key. Replays with the same
  /// payload return the original record; reusing a key for different data fails.
  Future<FeePaymentRecord> recordFeePayment({
    required int feeChargeId,
    required int amountPaise,
    required String method,
    required String idempotencyKey,
    DateTime? receivedAt,
    String? reference,
  }) async {
    if (feeChargeId <= 0) {
      throw ArgumentError.value(feeChargeId, 'feeChargeId', 'Must be positive');
    }
    if (amountPaise <= 0) {
      throw ArgumentError.value(amountPaise, 'amountPaise', 'Must be positive');
    }
    const allowedMethods = {
      'cash',
      'upi',
      'bank_transfer',
      'card',
      'cheque',
      'other',
    };
    final normalizedMethod = method.trim().toLowerCase();
    if (!allowedMethods.contains(normalizedMethod)) {
      throw ArgumentError.value(method, 'method', 'Unsupported payment method');
    }
    final normalizedKey = idempotencyKey.trim();
    if (normalizedKey.isEmpty || normalizedKey.length > 120) {
      throw ArgumentError.value(
        idempotencyKey,
        'idempotencyKey',
        'Must be 1 to 120 characters',
      );
    }
    final normalizedReference =
        reference == null || reference.trim().isEmpty ? null : reference.trim();
    if (normalizedReference != null && normalizedReference.length > 120) {
      throw ArgumentError.value(
        reference,
        'reference',
        'Must be at most 120 characters',
      );
    }
    final requestedReceivedAtMillis = receivedAt?.millisecondsSinceEpoch;
    final paymentDate = receivedAt ?? DateTime.now();
    final receivedAtMillis = paymentDate.millisecondsSinceEpoch;

    return transaction(() async {
      final existingRows = await customSelect(
        'SELECT * FROM fee_payments WHERE idempotency_key = ?',
        variables: [Variable.withString(normalizedKey)],
      ).get();
      if (existingRows.isNotEmpty) {
        final existing = FeePaymentRecord.fromRow(existingRows.single);
        final matches = existing.feeChargeId == feeChargeId &&
            existing.amountPaise == amountPaise &&
            existing.method == normalizedMethod &&
            existing.reference == normalizedReference &&
            (requestedReceivedAtMillis == null ||
                existing.receivedAt.millisecondsSinceEpoch ==
                    requestedReceivedAtMillis);
        if (!matches) {
          throw StateError(
            'Idempotency key was already used for a different payment',
          );
        }
        return existing;
      }

      // Re-check the charge balance inside the same transaction as the
      // insert. UI validation alone can be stale if two submissions race.
      final chargeRows = await customSelect(
        'SELECT amount_paise FROM fee_charges WHERE id = ?',
        variables: [Variable.withInt(feeChargeId)],
      ).get();
      if (chargeRows.isEmpty) {
        throw StateError('Fee charge does not exist');
      }
      final chargeAmount = chargeRows.single.read<int>('amount_paise');
      final paidRows = await customSelect(
        'SELECT COALESCE(SUM(amount_paise), 0) AS total_paid '
        'FROM fee_payments WHERE fee_charge_id = ?',
        variables: [Variable.withInt(feeChargeId)],
      ).get();
      final totalPaid = paidRows.single.read<int>('total_paid');
      if (amountPaise > chargeAmount - totalPaid) {
        throw StateError('Payment exceeds the outstanding fee balance');
      }

      await customStatement(
        '''INSERT INTO fee_payments
          (fee_charge_id, amount_paise, method, reference, idempotency_key,
           received_at, created_at)
          VALUES (?, ?, ?, ?, ?, ?, ?)''',
        [
          feeChargeId,
          amountPaise,
          normalizedMethod,
          normalizedReference,
          normalizedKey,
          receivedAtMillis,
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
      final insertedRows = await customSelect(
        'SELECT * FROM fee_payments WHERE idempotency_key = ?',
        variables: [Variable.withString(normalizedKey)],
      ).get();
      return FeePaymentRecord.fromRow(insertedRows.single);
    });
  }

  Future<List<FeePaymentRecord>> getFeePaymentsForCharge(
    int feeChargeId,
  ) async {
    final rows = await customSelect(
      '''SELECT * FROM fee_payments
         WHERE fee_charge_id = ?
         ORDER BY received_at DESC, id DESC''',
      variables: [Variable.withInt(feeChargeId)],
    ).get();
    return rows.map(FeePaymentRecord.fromRow).toList(growable: false);
  }

  Future<int> getTotalPaidForCharge(int feeChargeId) async {
    final rows = await customSelect(
      '''SELECT COALESCE(SUM(amount_paise), 0) AS total_paid
         FROM fee_payments WHERE fee_charge_id = ?''',
      variables: [Variable.withInt(feeChargeId)],
    ).get();
    return rows.single.read<int>('total_paid');
  }

  Future<Institute?> getInstitute() =>
      (select(institutes)..limit(1)).getSingleOrNull();

  Future<void> saveInstitute({
    required String name,
    required String academicYear,
    String? phone,
  }) async {
    final existing = await getInstitute();
    final values = InstitutesCompanion(
      name: Value(name.trim()),
      academicYear: Value(academicYear.trim()),
      phone: Value(phone == null || phone.trim().isEmpty ? null : phone.trim()),
    );
    if (existing == null) {
      await into(institutes).insert(values);
    } else {
      await (update(institutes)..where((row) => row.id.equals(existing.id)))
          .write(values);
    }
  }

  Future<List<ClassBatch>> searchClasses(String query) {
    final normalized = query.trim();
    final statement = select(classes)
      ..orderBy([
        (row) => OrderingTerm.asc(row.academicYear),
        (row) => OrderingTerm.asc(row.name),
      ]);
    if (normalized.isNotEmpty) {
      statement.where((row) =>
          row.name.like('%$normalized%') |
          row.academicYear.like('%$normalized%') |
          row.description.like('%$normalized%'));
    }
    return statement.get();
  }

  Future<ClassBatch?> getClass(int id) =>
      (select(classes)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<bool> classExists({
    required String name,
    required String academicYear,
    int? excludingId,
  }) async {
    final variables = <Variable<Object>>[
      Variable.withString(name.trim().toLowerCase()),
      Variable.withString(academicYear.trim().toLowerCase()),
    ];
    final exclusion = excludingId == null ? '' : 'AND id != ?';
    if (excludingId != null) variables.add(Variable.withInt(excludingId));
    final existing = await customSelect(
      'SELECT 1 AS matched FROM classes '
      'WHERE lower(trim(name)) = ? AND lower(trim(academic_year)) = ? '
      '$exclusion LIMIT 1',
      variables: variables,
    ).getSingleOrNull();
    return existing != null;
  }

  Future<int> saveClass({
    int? id,
    required String name,
    required String academicYear,
    String? description,
  }) async {
    if (await classExists(
      name: name,
      academicYear: academicYear,
      excludingId: id,
    )) {
      throw StateError('A class with this name already exists for this year');
    }
    final now = DateTime.now();
    final values = ClassesCompanion(
      name: Value(name.trim()),
      academicYear: Value(academicYear.trim()),
      description: Value(
        description == null || description.trim().isEmpty
            ? null
            : description.trim(),
      ),
      updatedAt: Value(now),
    );
    if (id == null) return into(classes).insert(values);
    await (update(classes)..where((row) => row.id.equals(id))).write(values);
    return id;
  }

  /// Deletes a class only when it has no batches, and safely unassigns its students.
  /// This explicit transaction keeps the app's deletion policy consistent even
  /// when a SQLite executor does not enable foreign-key enforcement.
  Future<void> deleteClass(int id) async {
    await transaction(() async {
      final batchCount = await countBatches(id);
      if (batchCount > 0) {
        throw StateError('A class with batches cannot be deleted');
      }
      final assignmentCount = await customSelect(
        'SELECT COUNT(*) AS total FROM student_assignments WHERE class_id = ?',
        variables: [Variable.withInt(id)],
      ).getSingle().then((row) => row.read<int>('total'));
      if (assignmentCount > 0) {
        throw StateError(
            'A class referenced by assignment history cannot be deleted');
      }

      await (update(students)..where((row) => row.classId.equals(id))).write(
        StudentsCompanion(
          classId: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
      await (delete(classes)..where((row) => row.id.equals(id))).go();
    });
  }

  Future<void> setClassActive(int id, {required bool isActive}) async {
    await (update(classes)..where((row) => row.id.equals(id))).write(
      ClassesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<List<ClassBatchSession>> getBatches(int classId) => (select(batches)
        ..where((row) => row.classId.equals(classId))
        ..orderBy([(row) => OrderingTerm.asc(row.name)]))
      .get();

  Future<ClassBatchSession?> getBatch(int id) =>
      (select(batches)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<bool> batchExists({
    required int classId,
    required String name,
    int? excludingId,
  }) async {
    final variables = <Variable<Object>>[
      Variable.withInt(classId),
      Variable.withString(name.trim().toLowerCase()),
    ];
    final exclusion = excludingId == null ? '' : 'AND id != ?';
    if (excludingId != null) variables.add(Variable.withInt(excludingId));
    final existing = await customSelect(
      'SELECT 1 AS matched FROM batches WHERE class_id = ? '
      'AND lower(trim(name)) = ? $exclusion LIMIT 1',
      variables: variables,
    ).getSingleOrNull();
    return existing != null;
  }

  Future<int> saveBatch({
    int? id,
    required int classId,
    required String name,
    String? subject,
    String? timing,
    String? teacherName,
    int? monthlyFeePaise,
  }) async {
    if (await batchExists(
      classId: classId,
      name: name,
      excludingId: id,
    )) {
      throw StateError('A batch with this name already exists in this class');
    }
    String? optionalText(String? value) =>
        value == null || value.trim().isEmpty ? null : value.trim();
    final values = BatchesCompanion(
      classId: Value(classId),
      name: Value(name.trim()),
      subject: Value(optionalText(subject)),
      timing: Value(optionalText(timing)),
      teacherName: Value(optionalText(teacherName)),
      monthlyFeePaise: Value(monthlyFeePaise),
      updatedAt: Value(DateTime.now()),
    );
    if (id == null) return into(batches).insert(values);
    await (update(batches)..where((row) => row.id.equals(id))).write(values);
    return id;
  }

  Future<void> setBatchActive(int id, {required bool isActive}) async {
    await (update(batches)..where((row) => row.id.equals(id))).write(
      BatchesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> countBatches(int classId) async {
    final count = batches.id.count();
    final query = selectOnly(batches)
      ..addColumns([count])
      ..where(batches.classId.equals(classId));
    return await query.map((row) => row.read(count) ?? 0).getSingle();
  }

  Future<List<Student>> searchStudents(String query) {
    final normalized = query.trim();
    final statement = select(students)
      ..orderBy([(row) => OrderingTerm.asc(row.fullName)]);
    if (normalized.isNotEmpty) {
      statement.where((row) =>
          row.fullName.like('%$normalized%') |
          row.admissionNumber.like('%$normalized%'));
    }
    return statement.get();
  }

  Future<Student?> getStudent(int id) =>
      (select(students)..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<bool> studentAdmissionNumberExists({
    required String admissionNumber,
    int? excludingId,
  }) async {
    final normalized = admissionNumber.trim().toUpperCase();
    final existing = await (select(students)
          ..where((row) => row.admissionNumber.equals(normalized)))
        .getSingleOrNull();
    return existing != null && existing.id != excludingId;
  }

  Future<int> saveStudent({
    int? id,
    required String admissionNumber,
    required String fullName,
    String? phone,
    String? guardianName,
    int? classId,
  }) async {
    final now = DateTime.now();
    return transaction(() async {
      final existing = id == null ? null : await getStudent(id);
      if (id != null && existing == null) {
        throw StateError('Student does not exist');
      }
      final values = StudentsCompanion(
        admissionNumber: Value(admissionNumber.trim().toUpperCase()),
        fullName: Value(fullName.trim()),
        phone: Value(
          phone == null || phone.trim().isEmpty ? null : phone.trim(),
        ),
        guardianName: Value(
          guardianName == null || guardianName.trim().isEmpty
              ? null
              : guardianName.trim(),
        ),
        // Assignment changes are written through the history ledger below.
        classId: Value(existing?.classId),
        updatedAt: Value(now),
      );

      final studentId = id ?? await into(students).insert(values);
      if (id != null) {
        await (update(students)..where((row) => row.id.equals(id)))
            .write(values);
      }

      if (classId != existing?.classId) {
        if (classId == null) {
          final currentAssignment =
              await getCurrentStudentAssignment(studentId);
          final effectiveTo = currentAssignment != null &&
                  now.difference(currentAssignment.effectiveFrom) <
                      const Duration(seconds: 1)
              ? currentAssignment.effectiveFrom.add(const Duration(seconds: 1))
              : now;
          await clearStudentAssignment(
            studentId: studentId,
            effectiveTo: effectiveTo,
            reason: 'Class assignment removed from student form',
          );
        } else {
          await assignStudentToClass(
            studentId: studentId,
            classId: classId,
            effectiveFrom: now,
            reason: existing?.classId == null
                ? 'Initial class assignment'
                : 'Class transfer from student form',
          );
        }
      }
      return studentId;
    });
  }

  Future<List<StudentAssignment>> getStudentAssignmentHistory(int studentId) =>
      (select(studentAssignments)
            ..where((row) => row.studentId.equals(studentId))
            ..orderBy([(row) => OrderingTerm.asc(row.effectiveFrom)]))
          .get();

  Future<StudentAssignment?> getCurrentStudentAssignment(int studentId) =>
      (select(studentAssignments)
            ..where((row) =>
                row.studentId.equals(studentId) & row.effectiveTo.isNull()))
          .getSingleOrNull();

  /// Transfers a student without overwriting their previous placement.
  /// The end of the old assignment is exclusive, matching the new start.
  Future<int> assignStudentToClass({
    required int studentId,
    required int classId,
    int? batchId,
    required DateTime effectiveFrom,
    String? reason,
  }) async {
    if (effectiveFrom.isAfter(DateTime.now())) {
      throw StateError('Future-dated assignments are not supported yet');
    }
    final trimmedReason = reason?.trim();
    final normalizedReason =
        trimmedReason?.isNotEmpty == true ? trimmedReason : null;
    if (normalizedReason != null && normalizedReason.length > 240) {
      throw ArgumentError('Transfer reason must be 240 characters or fewer');
    }
    return transaction(() async {
      final student = await getStudent(studentId);
      if (student == null) throw StateError('Student does not exist');
      final targetClass = await getClass(classId);
      if (targetClass == null) throw StateError('Target class does not exist');
      if (batchId != null) {
        final targetBatch = await getBatch(batchId);
        if (targetBatch == null || targetBatch.classId != classId) {
          throw StateError('Selected batch must belong to the target class');
        }
      }

      final current = await getCurrentStudentAssignment(studentId);
      if (current != null) {
        if (!effectiveFrom.isAfter(current.effectiveFrom)) {
          throw StateError(
              'Transfer date must be after the current assignment start');
        }
        await (update(studentAssignments)
              ..where((row) => row.id.equals(current.id)))
            .write(StudentAssignmentsCompanion(
          effectiveTo: Value(effectiveFrom),
          endReason: Value(normalizedReason),
        ));
      } else if (student.classId != null) {
        // A legacy/unmigrated assignment should never be silently discarded.
        throw StateError(
            'Student has a class but no assignment history; review data first');
      }

      final assignmentId = await into(studentAssignments).insert(
        StudentAssignmentsCompanion.insert(
          studentId: studentId,
          classId: classId,
          batchId: Value(batchId),
          effectiveFrom: effectiveFrom,
          transferReason: Value(normalizedReason),
        ),
      );
      await (update(students)..where((row) => row.id.equals(studentId))).write(
        StudentsCompanion(
          classId: Value(classId),
          updatedAt: Value(DateTime.now()),
        ),
      );
      return assignmentId;
    });
  }

  Future<void> clearStudentAssignment({
    required int studentId,
    required DateTime effectiveTo,
    String? reason,
  }) async {
    final normalizedReason =
        reason == null || reason.trim().isEmpty ? null : reason.trim();
    await transaction(() async {
      final student = await getStudent(studentId);
      if (student == null) throw StateError('Student does not exist');
      final current = await getCurrentStudentAssignment(studentId);
      if (current == null) {
        if (student.classId != null) {
          throw StateError(
              'Student has a class but no assignment history; review data first');
        }
        return;
      }
      if (!effectiveTo.isAfter(current.effectiveFrom)) {
        throw StateError('End date must be after the assignment start');
      }
      await (update(studentAssignments)
            ..where((row) => row.id.equals(current.id)))
          .write(StudentAssignmentsCompanion(
        effectiveTo: Value(effectiveTo),
        endReason: Value(normalizedReason),
      ));
      await (update(students)..where((row) => row.id.equals(studentId))).write(
        StudentsCompanion(
          classId: const Value(null),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> setStudentActive(int id, {required bool isActive}) async {
    await (update(students)..where((row) => row.id.equals(id))).write(
      StudentsCompanion(
        isActive: Value(isActive),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}

/// Immutable payment record returned by the fee payment database APIs.
class FeePaymentRecord {
  const FeePaymentRecord({
    required this.id,
    required this.feeChargeId,
    required this.amountPaise,
    required this.method,
    required this.reference,
    required this.idempotencyKey,
    required this.receivedAt,
    required this.createdAt,
  });

  final int id;
  final int feeChargeId;
  final int amountPaise;
  final String method;
  final String? reference;
  final String idempotencyKey;
  final DateTime receivedAt;
  final DateTime createdAt;

  factory FeePaymentRecord.fromRow(QueryRow row) => FeePaymentRecord(
        id: row.read<int>('id'),
        feeChargeId: row.read<int>('fee_charge_id'),
        amountPaise: row.read<int>('amount_paise'),
        method: row.read<String>('method'),
        reference: row.readNullable<String>('reference'),
        idempotencyKey: row.read<String>('idempotency_key'),
        receivedAt: DateTime.fromMillisecondsSinceEpoch(
          row.read<int>('received_at'),
        ),
        createdAt: DateTime.fromMillisecondsSinceEpoch(
          row.read<int>('created_at'),
        ),
      );
}
