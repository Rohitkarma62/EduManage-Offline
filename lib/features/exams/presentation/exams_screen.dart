import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/database/database_provider.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  late Future<_ExamPageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ExamPageData> _load() async {
    final db = ref.read(appDatabaseProvider);
    final classes = await db
        .customSelect(
          'SELECT id, name, academic_year FROM classes ORDER BY academic_year DESC, name COLLATE NOCASE',
        )
        .get();
    final exams = await db.getExams();
    return _ExamPageData(classes, exams);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _createExam(List<QueryRow> classes) async {
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Create a class before adding an exam.')),
      );
      return;
    }
    final input = await showDialog<_ExamInput>(
      context: context,
      builder: (_) => _ExamDialog(classes: classes),
    );
    if (input == null || !mounted) return;
    try {
      await ref.read(appDatabaseProvider).saveExam(
            classId: input.classId,
            title: input.title,
            subject: input.subject,
            examDate: input.date,
            maxMarks: input.maxMarks,
          );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exam created and saved offline.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create exam: $error')),
        );
      }
    }
  }

  String _dateLabel(int millis) {
    final date = DateTime.fromMillisecondsSinceEpoch(millis);
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exams & results')),
      body: FutureBuilder<_ExamPageData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Could not load exams: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Exam register',
                                  style:
                                      Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 4),
                              Text(
                                  '${data.exams.length} exams saved on this device'),
                            ],
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _createExam(data.classes),
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: data.exams.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                              'No exams yet. Add an exam to start entering student results.'),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: data.exams.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final exam = data.exams[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                  child: Icon(Icons.assignment_outlined)),
                              title: Text(exam.read<String>('title')),
                              subtitle: Text(
                                '${exam.read<String>('subject')} • ${exam.read<String>('class_name')}\n'
                                '${_dateLabel(exam.read<int>('exam_date'))} • Max ${exam.read<int>('max_marks')} marks • '
                                '${exam.read<int>('result_count')} results entered',
                              ),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(
                                  '/exams/${exam.read<int>('id')}/results'),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ExamResultsScreen extends ConsumerStatefulWidget {
  const ExamResultsScreen({required this.examId, super.key});
  final int examId;

  @override
  ConsumerState<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends ConsumerState<ExamResultsScreen> {
  late Future<_ResultsData> _future;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_ResultsData> _load() async {
    final db = ref.read(appDatabaseProvider);
    final exam = await db.customSelect(
      '''SELECT e.id, e.title, e.subject, e.exam_date, e.max_marks, c.name AS class_name
         FROM exams e JOIN classes c ON c.id = e.class_id WHERE e.id = ?''',
      variables: [Variable.withInt(widget.examId)],
    ).getSingleOrNull();
    if (exam == null) throw StateError('Exam not found.');
    final students = await db.getStudentsForExam(widget.examId);
    final summary = await db.getExamSummary(widget.examId);
    return _ResultsData(exam, students, summary);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _printResultSheet(_ResultsData data) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final institute = await db
          .customSelect(
            'SELECT name, academic_year, phone FROM institutes LIMIT 1',
          )
          .getSingleOrNull();
      final maxMarks = data.exam.read<int>('max_marks');
      final examId = data.exam.read<int>('id');
      final date = DateTime.fromMillisecondsSinceEpoch(
        data.exam.read<int>('exam_date'),
      );
      final dateLabel =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      final document = pw.Document();
      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(28),
          build: (context) => [
            if (institute != null) ...[
              pw.Center(
                child: pw.Text(
                  institute.read<String>('name'),
                  style: const pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Academic year: ${institute.read<String>('academic_year')}${institute.read<String?>('phone') == null ? '' : ' • ${institute.read<String>('phone')}'}',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
              pw.SizedBox(height: 12),
            ],
            pw.Center(
              child: pw.Text(
                'EXAM RESULT SHEET',
                style: const pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('Exam: ${data.exam.read<String>('title')}'),
            pw.Text('Subject: ${data.exam.read<String>('subject')}'),
            pw.Text('Class: ${data.exam.read<String>('class_name')}'),
            pw.Text('Exam date: $dateLabel    Maximum marks: $maxMarks'),
            pw.SizedBox(height: 14),
            pw.TableHelper.fromTextArray(
              headers: const [
                'S.No.',
                'Admission no.',
                'Student name',
                'Marks',
                'Result',
                'Remarks',
              ],
              data: [
                for (var index = 0; index < data.students.length; index++)
                  _resultPdfRow(data.students[index], index, maxMarks),
              ],
              headerStyle: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 8,
              ),
              cellStyle: const pw.TextStyle(fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              border: pw.TableBorder.all(color: PdfColors.grey500, width: 0.5),
              cellPadding: const pw.EdgeInsets.all(5),
            ),
            pw.SizedBox(height: 16),
            pw.Text(
              'Results entered: ${data.summary['enteredCount']} / ${data.students.length}    Average: ${data.summary['averageMarks']!.toStringAsFixed(1)}    Pass count: ${data.summary['passCount']}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 32),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text('Authorized signature: ____________________'),
            ),
          ],
        ),
      );
      await Printing.layoutPdf(
        name: 'exam-result-$examId.pdf',
        onLayout: (_) async => document.save(),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not prepare result PDF: $error')),
        );
      }
    }
  }

  List<String> _resultPdfRow(QueryRow student, int index, int maxMarks) {
    final marks = student.read<double?>('marks_obtained');
    final result = marks == null
        ? 'Pending'
        : marks >= maxMarks * 0.35
            ? 'Pass'
            : 'Needs review';
    final formattedMarks = marks == null
        ? 'Not entered'
        : '${marks.toStringAsFixed(2).replaceFirst(RegExp(r'\.0+$'), '')}/$maxMarks';
    return [
      '${index + 1}',
      student.read<String>('admission_number'),
      student.read<String>('full_name'),
      formattedMarks,
      result,
      student.read<String?>('remarks') ?? '',
    ];
  }

  Future<void> _printStudentResultCertificate(
    _ResultsData data,
    QueryRow student,
  ) async {
    final marks = student.read<double?>('marks_obtained');
    if (marks == null) return;
    try {
      final institute = await ref
          .read(appDatabaseProvider)
          .customSelect(
            'SELECT name, academic_year, phone FROM institutes LIMIT 1',
          )
          .getSingleOrNull();
      final exam = data.exam;
      final maxMarks = exam.read<int>('max_marks');
      final percentage = marks / maxMarks * 100;
      final passed = percentage >= 35;
      final examDate = DateTime.fromMillisecondsSinceEpoch(
        exam.read<int>('exam_date'),
      );
      String dateLabel(DateTime value) =>
          '${value.day.toString().padLeft(2, '0')}/'
          '${value.month.toString().padLeft(2, '0')}/${value.year}';
      String grade() {
        if (percentage >= 90) return 'A+';
        if (percentage >= 80) return 'A';
        if (percentage >= 70) return 'B+';
        if (percentage >= 60) return 'B';
        if (percentage >= 50) return 'C';
        if (percentage >= 35) return 'D';
        return 'Needs improvement';
      }

      final document = pw.Document();
      document.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(42),
        build: (_) => pw.Container(
          padding: const pw.EdgeInsets.all(28),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.blueGrey700, width: 2),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.SizedBox(height: 18),
              pw.Text(
                (institute?.read<String>('name') ?? 'Educational Institute')
                    .toUpperCase(),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blueGrey900,
                ),
              ),
              if (institute?.read<String?>('phone') != null)
                pw.Text('Phone: ${institute!.read<String>('phone')}'),
              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 22),
              pw.Text(
                'STUDENT RESULT CERTIFICATE',
                style: const pw.TextStyle(
                  fontSize: 19,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 28),
              pw.Text('This is to certify that'),
              pw.SizedBox(height: 10),
              pw.Text(
                student.read<String>('full_name'),
                style: const pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Admission Number: ${student.read<String>('admission_number')}',
              ),
              pw.SizedBox(height: 22),
              pw.Text(
                'has appeared in ${exam.read<String>('title')} '
                '(${exam.read<String>('subject')}) held on '
                '${dateLabel(examDate)} for academic session '
                '${institute?.read<String>('academic_year') ?? '____________'}.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 12, lineSpacing: 4),
              ),
              pw.SizedBox(height: 24),
              pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColors.grey600,
                  width: 0.6,
                ),
                children: [
                  _certificateTableRow('Subject', exam.read<String>('subject')),
                  _certificateTableRow('Marks obtained',
                      '${marks.toStringAsFixed(2)}/$maxMarks'),
                  _certificateTableRow(
                      'Percentage', '${percentage.toStringAsFixed(2)}%'),
                  _certificateTableRow('Grade', grade()),
                  _certificateTableRow(
                      'Result', passed ? 'PASS' : 'NEEDS IMPROVEMENT'),
                ],
              ),
              if ((student.read<String?>('remarks') ?? '').trim().isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 16),
                  child: pw.Text(
                    'Remarks: ${student.read<String>('remarks')}',
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Text('Date of issue: ${dateLabel(DateTime.now())}'),
              ),
              pw.SizedBox(height: 28),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(children: [
                  pw.SizedBox(width: 155, child: pw.Divider()),
                  pw.Text('Authorized Signature'),
                ]),
              ),
            ],
          ),
        ),
      ));
      await Printing.layoutPdf(
        name: 'result-certificate-${student.read<int>('student_id')}-'
            '${exam.read<int>('id')}.pdf',
        onLayout: (_) async => document.save(),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Could not generate result certificate: $error')),
        );
      }
    }
  }

  pw.TableRow _certificateTableRow(String label, String value) => pw.TableRow(
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(9),
            child: pw.Text(
              label,
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(9),
            child: pw.Text(value),
          ),
        ],
      );

  Future<void> _editMarks(QueryRow student, int maxMarks) async {
    if (_saving) return;
    final existing = student.read<double?>('marks_obtained');
    final controller = TextEditingController(
      text: existing == null ? '' : existing.toString(),
    );
    final remarksController = TextEditingController(
      text: student.read<String?>('remarks') ?? '',
    );
    final formKey = GlobalKey<FormState>();
    final result = await showDialog<_MarksInput>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(student.read<String>('full_name')),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    'Admission no. ${student.read<String>('admission_number')} • Maximum $maxMarks'),
                const SizedBox(height: 12),
                TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                      labelText: 'Marks obtained', hintText: 'e.g. 42 or 42.5'),
                  validator: (value) {
                    final marks = double.tryParse((value ?? '').trim());
                    if (marks == null ||
                        !marks.isFinite ||
                        marks < 0 ||
                        marks > maxMarks) {
                      return 'Enter a value from 0 to $maxMarks';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: remarksController,
                  maxLength: 240,
                  decoration:
                      const InputDecoration(labelText: 'Remarks (optional)'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                  dialogContext,
                  _MarksInput(
                    double.parse(controller.text.trim()),
                    remarksController.text.trim(),
                  ));
            },
            child: const Text('Save marks'),
          ),
        ],
      ),
    );
    controller.dispose();
    remarksController.dispose();
    if (result == null || !mounted) return;
    setState(() => _saving = true);
    try {
      await ref.read(appDatabaseProvider).saveExamResult(
            examId: widget.examId,
            studentId: student.read<int>('student_id'),
            marksObtained: result.marks,
            remarks: result.remarks,
          );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student result saved offline.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save result: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter results')),
      body: FutureBuilder<_ResultsData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Could not load results: ${snapshot.error}'));
          }
          final data = snapshot.data!;
          final maxMarks = data.exam.read<int>('max_marks');
          final entered = data.summary['enteredCount']!.toInt();
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.exam.read<String>('title'),
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                          '${data.exam.read<String>('subject')} • ${data.exam.read<String>('class_name')} • Max $maxMarks marks'),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _Metric(
                              label: 'Entered',
                              value: '$entered/${data.students.length}'),
                          _Metric(
                              label: 'Average',
                              value:
                                  '${data.summary['averageMarks']!.toStringAsFixed(1)}/$maxMarks'),
                          _Metric(
                              label: 'Pass (35%)',
                              value: '${data.summary['passCount']}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: () => _printResultSheet(data),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Print / export PDF'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: data.students.isEmpty
                    ? const Center(
                        child: Text(
                            'No students were assigned to this class on the exam date.'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: data.students.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 6),
                        itemBuilder: (context, index) {
                          final student = data.students[index];
                          final marks = student.read<double?>('marks_obtained');
                          final enteredMarks = marks == null
                              ? 'Not entered'
                              : '${marks.toStringAsFixed(2).replaceFirst(RegExp(r'\.0+$'), '')}/$maxMarks';
                          return Card(
                            child: ListTile(
                              title: Text(student.read<String>('full_name')),
                              subtitle: Text(
                                  'Admission no. ${student.read<String>('admission_number')} • $enteredMarks'),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    tooltip: marks == null
                                        ? 'Enter marks before generating certificate'
                                        : 'Generate result certificate',
                                    onPressed: _saving || marks == null
                                        ? null
                                        : () => _printStudentResultCertificate(
                                              data,
                                              student,
                                            ),
                                    icon: const Icon(
                                        Icons.picture_as_pdf_outlined),
                                  ),
                                  IconButton(
                                    tooltip: 'Enter or edit marks',
                                    onPressed: _saving
                                        ? null
                                        : () => _editMarks(student, maxMarks),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                ],
                              ),
                              onTap: _saving
                                  ? null
                                  : () => _editMarks(student, maxMarks),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ExamPageData {
  const _ExamPageData(this.classes, this.exams);
  final List<QueryRow> classes;
  final List<QueryRow> exams;
}

class _ResultsData {
  const _ResultsData(this.exam, this.students, this.summary);
  final QueryRow exam;
  final List<QueryRow> students;
  final Map<String, num> summary;
}

class _ExamInput {
  const _ExamInput(
      this.classId, this.title, this.subject, this.date, this.maxMarks);
  final int classId;
  final String title;
  final String subject;
  final DateTime date;
  final int maxMarks;
}

class _MarksInput {
  const _MarksInput(this.marks, this.remarks);
  final double marks;
  final String remarks;
}

class _ExamDialog extends StatefulWidget {
  const _ExamDialog({required this.classes});
  final List<QueryRow> classes;

  @override
  State<_ExamDialog> createState() => _ExamDialogState();
}

class _ExamDialogState extends State<_ExamDialog> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _subject = TextEditingController();
  final _maxMarks = TextEditingController(text: '100');
  late int _classId;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _classId = widget.classes.first.read<int>('id');
  }

  @override
  void dispose() {
    _title.dispose();
    _subject.dispose();
    _maxMarks.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Create exam'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<int>(
                  initialValue: _classId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: widget.classes
                      .map((row) => DropdownMenuItem<int>(
                            value: row.read<int>('id'),
                            child: Text(
                                '${row.read<String>('name')} • ${row.read<String>('academic_year')}'),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _classId = value);
                    }
                  },
                ),
                TextFormField(
                  controller: _title,
                  maxLength: 120,
                  decoration: const InputDecoration(
                      labelText: 'Exam name', hintText: 'Mid-term examination'),
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? 'Enter an exam name'
                      : null,
                ),
                TextFormField(
                  controller: _subject,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: 'Subject'),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Enter a subject' : null,
                ),
                TextFormField(
                  controller: _maxMarks,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Maximum marks'),
                  validator: (value) {
                    final marks = int.tryParse((value ?? '').trim());
                    return marks == null || marks < 1 || marks > 100000
                        ? 'Enter a value from 1 to 100000'
                        : null;
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Exam date'),
                  subtitle: Text(
                      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'),
                  trailing: const Icon(Icons.calendar_month_outlined),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null && mounted) {
                      setState(() => _date = picked);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (!_formKey.currentState!.validate()) return;
              Navigator.pop(
                  context,
                  _ExamInput(
                    _classId,
                    _title.text.trim(),
                    _subject.text.trim(),
                    _date,
                    int.parse(_maxMarks.text.trim()),
                  ));
            },
            child: const Text('Create exam'),
          ),
        ],
      );
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      );
}
