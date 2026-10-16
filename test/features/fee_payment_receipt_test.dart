import 'package:edumanage_offline/features/fees/fee_payment_receipt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds a valid PDF receipt with payment details', () async {
    final bytes = await buildFeePaymentReceiptPdf(
      FeePaymentReceiptData(
        instituteName: 'Demo Institute',
        academicYear: '2026-2027',
        phone: '9876543210',
        studentName: 'Aarav Sharma',
        admissionNumber: 'ADM-001',
        chargeTitle: 'Tuition fee',
        periodStart: DateTime(2026, 10, 1),
        periodEnd: DateTime(2026, 11, 1),
        dueDate: DateTime(2026, 10, 8),
        paymentId: 42,
        amountPaise: 250000,
        method: 'upi',
        reference: 'UPI-REF-42',
        receivedAt: DateTime(2026, 10, 15, 10, 30),
        chargeAmountPaise: 500000,
        totalPaidPaise: 350000,
      ),
    );

    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
  });

  test('builds receipts for every supported payment method without optional details',
      () async {
    const methods = [
      'cash',
      'upi',
      'bank_transfer',
      'card',
      'cheque',
      'other',
    ];

    for (final method in methods) {
      final bytes = await buildFeePaymentReceiptPdf(
        FeePaymentReceiptData(
          instituteName: '   ',
          academicYear: '2026-2027',
          phone: null,
          studentName: 'Aarav Sharma',
          admissionNumber: 'ADM-001',
          chargeTitle: 'Tuition fee',
          periodStart: DateTime(2026, 10, 1),
          periodEnd: DateTime(2026, 11, 1),
          dueDate: DateTime(2026, 10, 8),
          paymentId: 43,
          amountPaise: 10000,
          method: method,
          reference: null,
          receivedAt: DateTime(2026, 10, 16, 9, 5),
          chargeAmountPaise: 10000,
          totalPaidPaise: 10000,
        ),
      );

      expect(bytes, isNotEmpty, reason: 'method: $method');
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-',
          reason: 'method: $method');
    }
  });
}
