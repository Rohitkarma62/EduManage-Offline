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
}
