import 'package:drift/drift.dart' show QueryRow, Variable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';

class AttendanceReportsScreen extends ConsumerStatefulWidget {
  const AttendanceReportsScreen({super.key});

  @override
  ConsumerState<AttendanceReportsScreen> createState() =>
      _AttendanceReportsScreenState();
}

class _AttendanceReportsScreenState
    extends ConsumerState<AttendanceReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 29));
  DateTime _endDate = DateTime.now();
  int? _classId;
  int? _batchId;
  late Future<_ReportData> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _loadReport();
  }

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  String _dateLabel(DateTime date) => '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  Future<_ReportData> _loadReport() async {
    final db = ref.read(appDatabaseProvider);
    final classes = await db
        .customSelect(
          'SELECT id, name, academic_year FROM classes ORDER BY name COLLATE NOCASE',
        )
        .get();
    final batches = await db
        .customSelect(
          'SELECT id, class_id, name FROM batches ORDER BY name COLLATE NOCASE',
        )
        .get();

    final conditions = <String>[
      'ar.attendance_date >= ?',
      'ar.attendance_date <= ?',
    ];
    final variables = <Variable<Object>>[
      Variable.withString(_dateKey(_startDate)),
      Variable.withString(_dateKey(_endDate)),
    ];
    if (_classId != null) {
      conditions.add('sa.class_id = ?');
      variables.add(Variable.withInt(_classId!));
    }
    if (_batchId != null) {
      conditions.add('sa.batch_id = ?');
      variables.add(Variable.withInt(_batchId!));
    }

    final reportRows = await db.customSelect('''
      SELECT s.id AS student_id, s.full_name AS full_name,
             s.admission_number AS admission_number,
             c.name AS class_name, b.name AS batch_name,
             SUM(CASE WHEN ar.status = 'present' THEN 1 ELSE 0 END) AS present_count,
             SUM(CASE WHEN ar.status = 'absent' THEN 1 ELSE 0 END) AS absent_count,
             SUM(CASE WHEN ar.status = 'leave' THEN 1 ELSE 0 END) AS leave_count,
             COUNT(ar.id) AS marked_count
      FROM attendance_records ar
      JOIN students s ON s.id = ar.student_id
      JOIN student_assignments sa
        ON sa.student_id = s.id
       AND sa.effective_from <= ar.attendance_date
       AND (sa.effective_to IS NULL OR sa.effective_to > ar.attendance_date)
      JOIN classes c ON c.id = sa.class_id
      LEFT JOIN batches b ON b.id = sa.batch_id
      WHERE ${conditions.join(' AND ')}
      GROUP BY s.id, s.full_name, s.admission_number, c.name, b.name
      ORDER BY s.full_name COLLATE NOCASE, s.id
    ''', variables: variables).get();

    return _ReportData(classes: classes, batches: batches, rows: reportRows);
  }

  Future<void> _pickDate({required bool start}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: start ? _startDate : _endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    final date = DateTime(picked.year, picked.month, picked.day);
    setState(() {
      if (start) {
        _startDate = date;
        if (_startDate.isAfter(_endDate)) _endDate = _startDate;
      } else {
        _endDate = date;
        if (_endDate.isBefore(_startDate)) _startDate = _endDate;
      }
      _reportFuture = _loadReport();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance reports')),
      body: FutureBuilder<_ReportData>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load report: ${snapshot.error}'),
              ),
            );
          }
          final data = snapshot.data!;
          final classOptions = [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All classes'),
            ),
            for (final row in data.classes)
              DropdownMenuItem<int?>(
                value: row.read<int>('id'),
                child: Text(
                  '${row.read<String>('name')} (${row.read<String>('academic_year')})',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ];
          final filteredBatches = data.batches.where((row) =>
              _classId == null || row.read<int>('class_id') == _classId);
          final batchOptions = [
            const DropdownMenuItem<int?>(
              value: null,
              child: Text('All batches'),
            ),
            for (final row in filteredBatches)
              DropdownMenuItem<int?>(
                value: row.read<int>('id'),
                child: Text(row.read<String>('name')),
              ),
          ];
          final present = _sum(data.rows, 'present_count');
          final absent = _sum(data.rows, 'absent_count');
          final leave = _sum(data.rows, 'leave_count');
          final denominator = present + absent;
          final percentage =
              denominator == 0 ? 0.0 : present * 100 / denominator;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _DateFilter(
                              label: 'From',
                              value: _dateLabel(_startDate),
                              onTap: () => _pickDate(start: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _DateFilter(
                              label: 'To',
                              value: _dateLabel(_endDate),
                              onTap: () => _pickDate(start: false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        initialValue: _classId,
                        decoration: const InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(),
                        ),
                        items: classOptions,
                        onChanged: (value) {
                          setState(() {
                            _classId = value;
                            if (_batchId != null &&
                                !data.batches.any((row) =>
                                    row.read<int>('id') == _batchId &&
                                    (value == null ||
                                        row.read<int>('class_id') == value))) {
                              _batchId = null;
                            }
                            _reportFuture = _loadReport();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int?>(
                        initialValue: _batchId,
                        decoration: const InputDecoration(
                          labelText: 'Batch',
                          border: OutlineInputBorder(),
                        ),
                        items: batchOptions,
                        onChanged: (value) {
                          setState(() {
                            _batchId = value;
                            _reportFuture = _loadReport();
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _startDate = DateTime.now()
                                  .subtract(const Duration(days: 29));
                              _endDate = DateTime.now();
                              _classId = null;
                              _batchId = null;
                              _reportFuture = _loadReport();
                            });
                          },
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reset filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      label: 'Present',
                      value: '$present',
                      icon: Icons.check_circle_outline,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Absent',
                      value: '$absent',
                      icon: Icons.cancel_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SummaryCard(
                      label: 'Leave',
                      value: '$leave',
                      icon: Icons.event_busy_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.percent),
                  title: const Text('Overall attendance'),
                  subtitle: const Text(
                      'Present ÷ (Present + Absent), excluding leave'),
                  trailing: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text('Student-wise report',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.rows.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No attendance records found for these filters and dates.',
                    ),
                  ),
                )
              else
                for (final row in data.rows) _StudentReportTile(row: row),
            ],
          );
        },
      ),
    );
  }

  int _sum(List<QueryRow> rows, String column) => rows.fold<int>(
        0,
        (total, row) => total + (row.read<int?>(column) ?? 0),
      );
}

class _ReportData {
  const _ReportData({
    required this.classes,
    required this.batches,
    required this.rows,
  });

  final List<QueryRow> classes;
  final List<QueryRow> batches;
  final List<QueryRow> rows;
}

class _DateFilter extends StatelessWidget {
  const _DateFilter({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          TextButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(value),
          ),
        ],
      );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      );
}

class _StudentReportTile extends StatelessWidget {
  const _StudentReportTile({required this.row});

  final QueryRow row;

  @override
  Widget build(BuildContext context) {
    final present = row.read<int?>('present_count') ?? 0;
    final absent = row.read<int?>('absent_count') ?? 0;
    final leave = row.read<int?>('leave_count') ?? 0;
    final denominator = present + absent;
    final percentage = denominator == 0 ? 0.0 : present * 100 / denominator;
    final batch = row.read<String?>('batch_name');

    return Card(
      child: ListTile(
        title: Text(row.read<String>('full_name')),
        subtitle: Text(
          '${row.read<String>('admission_number')} • '
          '${row.read<String>('class_name')}'
          '${batch == null ? '' : ' • $batch'}\n'
          'Present $present  •  Absent $absent  •  Leave $leave',
        ),
        isThreeLine: true,
        trailing: Text(
          '${percentage.toStringAsFixed(1)}%',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
