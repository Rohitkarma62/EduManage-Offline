import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The immutable data needed to create a printable fee payment receipt.
class FeePaymentReceiptData {
  const FeePaymentReceiptData({
    required this.instituteName,
    required this.academicYear,
    required this.phone,
    required this.studentName,
    required this.admissionNumber,
    required this.chargeTitle,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.paymentId,
    required this.amountPaise,
    required this.method,
    required this.reference,
    required this.receivedAt,
    required this.chargeAmountPaise,
    required this.totalPaidPaise,
  });

  final String instituteName;
  final String academicYear;
  final String? phone;
  final String studentName;
  final String admissionNumber;
  final String chargeTitle;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime dueDate;
  final int paymentId;
  final int amountPaise;
  final String method;
  final String? reference;
  final DateTime receivedAt;
  final int chargeAmountPaise;
  final int totalPaidPaise;
}

/// Creates a compact, offline-friendly PDF receipt.
Future<Uint8List> buildFeePaymentReceiptPdf(FeePaymentReceiptData data) async {
  final document = pw.Document();
  final receiptNumber =
      'EM-${data.receivedAt.year}${data.receivedAt.month.toString().padLeft(2, '0')}${data.receivedAt.day.toString().padLeft(2, '0')}-${data.paymentId.toString().padLeft(6, '0')}';
  String date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
  String money(int paise) => 'INR ${(paise / 100).toStringAsFixed(2)}';
  String method(String value) => switch (value) {
        'cash' => 'Cash',
        'upi' => 'UPI',
        'bank_transfer' => 'Bank transfer',
        'card' => 'Card',
        'cheque' => 'Cheque',
        _ => 'Other',
      };
  final balance = data.chargeAmountPaise - data.totalPaidPaise;

  document.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Center(
            child: pw.Text(
              data.instituteName.trim().isEmpty
                  ? 'Educational Institute'
                  : data.instituteName,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Center(child: pw.Text('Fee payment receipt')),
          if (data.phone?.trim().isNotEmpty == true) ...[
            pw.SizedBox(height: 3),
            pw.Center(child: pw.Text('Phone: ${data.phone}')),
          ],
          pw.SizedBox(height: 20),
          pw.Divider(),
          _receiptRow('Receipt no.', receiptNumber),
          _receiptRow('Payment date', '${date(data.receivedAt)} ${data.receivedAt.hour.toString().padLeft(2, '0')}:${data.receivedAt.minute.toString().padLeft(2, '0')}'),
          _receiptRow('Academic year', data.academicYear),
          pw.SizedBox(height: 12),
          pw.Text('STUDENT DETAILS',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _receiptRow('Student', data.studentName),
          _receiptRow('Admission no.', data.admissionNumber),
          pw.SizedBox(height: 12),
          pw.Text('FEE DETAILS',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _receiptRow('Fee', data.chargeTitle),
          _receiptRow(
            'Fee period',
            '${date(data.periodStart)} to ${date(data.periodEnd)} (end exclusive)',
          ),
          _receiptRow('Due date', date(data.dueDate)),
          pw.SizedBox(height: 12),
          pw.Text('PAYMENT DETAILS',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          _receiptRow('Amount received', money(data.amountPaise)),
          _receiptRow('Payment method', method(data.method)),
          if (data.reference?.trim().isNotEmpty == true)
            _receiptRow('Reference', data.reference!),
          pw.Divider(),
          _receiptRow('Total fee', money(data.chargeAmountPaise)),
          _receiptRow('Total paid to date', money(data.totalPaidPaise)),
          _receiptRow('Current outstanding balance', money(balance)),
          pw.Spacer(),
          pw.Divider(),
          pw.Center(
            child: pw.Text(
              'This receipt was generated offline by EduManage.',
              style: pw.TextStyle(fontSize: 9),
              textAlign: pw.TextAlign.center,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Center(
            child: pw.Text('Please retain this receipt for your records.',
                style: pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    ),
  );

  return document.save();
}

pw.Widget _receiptRow(String label, String value) => pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 155,
            child: pw.Text(label,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ),
          pw.Expanded(child: pw.Text(value)),
        ],
      ),
    );
