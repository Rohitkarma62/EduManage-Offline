import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/database/database_provider.dart';

class StudentCertificateScreen extends ConsumerStatefulWidget {
  const StudentCertificateScreen({required this.studentId, super.key});

  final int studentId;

  @override
  ConsumerState<StudentCertificateScreen> createState() =>
      _StudentCertificateScreenState();
}

class _StudentCertificateScreenState
    extends ConsumerState<StudentCertificateScreen> {
  late Future<_CertificateData> _future;
  String _certificateType = 'Bonafide Certificate';
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_CertificateData> _load() async {
    final db = ref.read(appDatabaseProvider);
    final student = await db.customSelect(
      'SELECT full_name, admission_number, phone FROM students WHERE id = ?',
      variables: [Variable.withInt(widget.studentId)],
    ).getSingleOrNull();
    if (student == null) throw StateError('Student not found.');
    final institute = await db
        .customSelect(
          'SELECT name, academic_year, phone FROM institutes LIMIT 1',
        )
        .getSingleOrNull();
    return _CertificateData(student, institute);
  }

  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<void> _printCertificate(_CertificateData data) async {
    if (_printing) return;
    setState(() => _printing = true);
    try {
      final studentName = data.student.read<String>('full_name');
      final admissionNumber = data.student.read<String>('admission_number');
      final instituteName =
          data.institute?.read<String>('name') ?? 'Educational Institute';
      final date = _dateLabel(DateTime.now());
      final document = pw.Document();
      document.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(52),
          build: (_) => pw.Container(
            padding: const pw.EdgeInsets.all(28),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(width: 2, color: PdfColors.blueGrey700),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 24),
                pw.Text(
                  instituteName.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                if (data.institute?.read<String?>('phone') != null)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(top: 5),
                    child: pw.Text(
                      'Phone: ${data.institute!.read<String>('phone')}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ),
                pw.SizedBox(height: 28),
                pw.Divider(thickness: 1.5),
                pw.SizedBox(height: 24),
                pw.Text(
                  _certificateType.toUpperCase(),
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 19,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                pw.SizedBox(height: 38),
                pw.Text(
                  'This is to certify that',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 14),
                pw.Text(
                  studentName,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(
                    fontSize: 25,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blueGrey900,
                  ),
                ),
                pw.SizedBox(height: 18),
                pw.Text(
                  'Admission Number: $admissionNumber',
                  style: const pw.TextStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  _certificateType == 'Bonafide Certificate'
                      ? 'is/was a student of this institute during the academic session '
                          '${data.institute?.read<String>('academic_year') ?? '____________'}. '
                          'This certificate is issued on request for official use.'
                      : 'has been associated with this institute. This certificate is issued '
                          'on request for official use.',
                  textAlign: pw.TextAlign.justify,
                  style: const pw.TextStyle(fontSize: 13, lineSpacing: 5),
                ),
                pw.Spacer(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Date: $date'),
                        pw.SizedBox(height: 4),
                        pw.Text('Place: __________________'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.SizedBox(width: 150, child: pw.Divider()),
                        pw.Text('Authorized Signature'),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 18),
              ],
            ),
          ),
        ),
      );
      await Printing.layoutPdf(
        name: 'student-certificate-${widget.studentId}.pdf',
        onLayout: (_) async => document.save(),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not generate certificate: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student certificates')),
      body: FutureBuilder<_CertificateData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Could not load student: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading:
                      const CircleAvatar(child: Icon(Icons.school_outlined)),
                  title: Text(data.student.read<String>('full_name')),
                  subtitle: Text(
                    'Admission no. ${data.student.read<String>('admission_number')}',
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _certificateType,
                decoration: const InputDecoration(
                  labelText: 'Certificate type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Bonafide Certificate',
                    child: Text('Bonafide Certificate'),
                  ),
                  DropdownMenuItem(
                    value: 'Character Certificate',
                    child: Text('Character Certificate'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _certificateType = value);
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'The certificate is generated offline as an A4 PDF. Review the '
                'student and institute details before printing or sharing.',
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _printing ? null : () => _printCertificate(data),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(
                    _printing ? 'Preparing PDF…' : 'Generate certificate PDF'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CertificateData {
  const _CertificateData(this.student, this.institute);

  final QueryRow student;
  final QueryRow? institute;
}
