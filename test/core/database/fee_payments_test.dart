import 'package:drift/native.dart';
import 'package:edumanage_offline/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase database;
  late int studentId;
  late int feeChargeId;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    final classId = await database.saveClass(
      name: 'Class 10',
      academicYear: '2026-2027',
    );
    studentId = await database.saveStudent(
      admissionNumber: 'ADM-001',
      fullName: 'Test Student',
      classId: classId,
    );
    final assignment = await database.getCurrentStudentAssignment(studentId);
    feeChargeId = await database.createFeeCharge(
      studentId: studentId,
      assignmentId: assignment!.id,
      title: 'October tuition',
      amountPaise: 125000,
      periodStart: DateTime(2026, 10, 1),
      periodEnd: DateTime(2026, 11, 1),
      dueDate: DateTime(2026, 10, 10),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('records and lists payments and totals paise accurately', () async {
    final receivedAt = DateTime(2026, 10, 10, 9);
    final first = await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 50000,
      method: 'UPI',
      idempotencyKey: 'upi-txn-001',
      reference: '  UTR123  ',
      receivedAt: receivedAt,
    );
    await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 25000,
      method: 'cash',
      idempotencyKey: 'cash-receipt-002',
      receivedAt: DateTime(2026, 10, 11, 10),
    );

    final payments = await database.getFeePaymentsForCharge(feeChargeId);
    expect(payments, hasLength(2));
    expect(payments.first.amountPaise, 25000);
    expect(payments.last.id, first.id);
    expect(first.method, 'upi');
    expect(first.reference, 'UTR123');
    expect(first.receivedAt, receivedAt);
    expect(await database.getTotalPaidForCharge(feeChargeId), 75000);
    expect(await database.getTotalPaidForCharge(-999), 0);
  });

  test('replaying an idempotency key returns the original payment', () async {
    final first = await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 10000,
      method: 'cash',
      idempotencyKey: 'retry-safe-payment',
    );
    final replay = await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 10000,
      method: 'CASH',
      idempotencyKey: 'retry-safe-payment',
    );

    expect(replay.id, first.id);
    expect(await database.getFeePaymentsForCharge(feeChargeId), hasLength(1));
    expect(await database.getTotalPaidForCharge(feeChargeId), 10000);
  });

  test('rejects reusing an idempotency key with a different payload', () async {
    await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 10000,
      method: 'cash',
      idempotencyKey: 'one-key-one-payment',
    );

    await expectLater(
      database.recordFeePayment(
        feeChargeId: feeChargeId,
        amountPaise: 20000,
        method: 'cash',
        idempotencyKey: 'one-key-one-payment',
      ),
      throwsStateError,
    );
    expect(await database.getTotalPaidForCharge(feeChargeId), 10000);
  });

  test('validates amounts, methods, and idempotency keys', () async {
    Future<void> record({
      int amountPaise = 100,
      String method = 'cash',
      String idempotencyKey = 'valid-key',
    }) async {
      await database.recordFeePayment(
        feeChargeId: feeChargeId,
        amountPaise: amountPaise,
        method: method,
        idempotencyKey: idempotencyKey,
      );
    }

    await expectLater(record(amountPaise: 0), throwsArgumentError);
    await expectLater(record(amountPaise: -1), throwsArgumentError);
    await expectLater(record(method: 'crypto'), throwsArgumentError);
    await expectLater(record(idempotencyKey: '  '), throwsArgumentError);
    await expectLater(record(idempotencyKey: 'x' * 121), throwsArgumentError);
    expect(await database.getFeePaymentsForCharge(feeChargeId), isEmpty);
  });

  test('rejects a payment that exceeds the remaining charge balance', () async {
    await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 100000,
      method: 'cash',
      idempotencyKey: 'almost-full-payment',
    );

    await expectLater(
      database.recordFeePayment(
        feeChargeId: feeChargeId,
        amountPaise: 25001,
        method: 'upi',
        idempotencyKey: 'over-balance-payment',
      ),
      throwsStateError,
    );

    expect(await database.getTotalPaidForCharge(feeChargeId), 100000);
    expect(await database.getFeePaymentsForCharge(feeChargeId), hasLength(1));
  });

  test('allows a payment exactly equal to the remaining balance', () async {
    await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 100000,
      method: 'cash',
      idempotencyKey: 'first-partial-payment',
    );
    await database.recordFeePayment(
      feeChargeId: feeChargeId,
      amountPaise: 25000,
      method: 'upi',
      idempotencyKey: 'final-payment',
    );

    expect(await database.getTotalPaidForCharge(feeChargeId), 125000);
  });

  test('database foreign key rejects payments for missing charges', () async {
    await expectLater(
      database.recordFeePayment(
        feeChargeId: 999999,
        amountPaise: 100,
        method: 'cash',
        idempotencyKey: 'missing-charge',
      ),
      throwsA(anything),
    );
  });
}
