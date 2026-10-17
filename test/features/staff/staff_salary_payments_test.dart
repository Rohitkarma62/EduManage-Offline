import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('records salary payment and includes it in monthly summary', () async {
    final staffId = await database.saveStaff(
      fullName: 'Asha Sharma',
      role: 'Teacher',
      monthlySalaryPaise: 3000000,
    );
    final paidAt = DateTime(2026, 10, 5);
    await database.recordStaffSalaryPayment(
      staffId: staffId,
      amountPaise: 1250000,
      paymentMethod: 'UPI',
      paidAt: paidAt,
      reference: 'UPI-123',
      notes: 'October part payment',
    );

    final payments = await database.getStaffSalaryPayments(staffId: staffId);
    expect(payments, hasLength(1));
    expect(payments.single.read<String>('staff_name'), 'Asha Sharma');
    expect(payments.single.read<int>('amount_paise'), 1250000);
    expect(payments.single.read<String>('payment_method'), 'UPI');
    expect(payments.single.read<String>('reference'), 'UPI-123');
    final summary = await database.getStaffSalarySummary(
      staffId: staffId,
      month: DateTime(2026, 10),
    );
    expect(summary['expectedPaise'], 3000000);
    expect(summary['paidPaise'], 1250000);
    expect(summary['pendingPaise'], 1750000);
  });

  test('rejects zero or negative salary payments', () async {
    final staffId = await database.saveStaff(fullName: 'Ravi Patel', role: 'Accountant');
    await expectLater(
      database.recordStaffSalaryPayment(
        staffId: staffId,
        amountPaise: 0,
        paymentMethod: 'Cash',
        paidAt: DateTime.now(),
      ),
      throwsArgumentError,
    );
    await expectLater(
      database.recordStaffSalaryPayment(
        staffId: staffId,
        amountPaise: -1,
        paymentMethod: 'Cash',
        paidAt: DateTime.now(),
      ),
      throwsArgumentError,
    );
  });

  test('does not allow payment against inactive staff', () async {
    final staffId = await database.saveStaff(fullName: 'Ravi Patel', role: 'Accountant');
    await database.setStaffActive(staffId, isActive: false);
    await expectLater(
      database.recordStaffSalaryPayment(
        staffId: staffId,
        amountPaise: 10000,
        paymentMethod: 'Cash',
        paidAt: DateTime.now(),
      ),
      throwsStateError,
    );
  });
}
