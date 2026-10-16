import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  late Future<List<QueryRow>> _recordsFuture;
  Map<int, String> _statuses = {};
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadRecords();
  }

  Future<List<QueryRow>> _loadRecords() async {
    final records = await ref
        .read(appDatabaseProvider)
        .getAttendanceForDate(_selectedDate);
    if (mounted) {
      setState(() {
        _statuses = {
          for (final row in records)
            if (row.read<String?>('attendance_status') != null)
              row.read<int>('student_id'):
                  row.read<String>('attendance_status'),
        };
      });
    }
    return records;
  }

  void _changeDate(DateTime date) {
    setState(() {
      _selectedDate = DateTime(date.year, date.month, date.day);
      _statuses = {};
      _recordsFuture = _loadRecords();
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select attendance date',
    );
    if (picked != null && mounted) _changeDate(picked);
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(appDatabaseProvider)
          .saveAttendanceForDate(_selectedDate, _statuses);
      if (!mounted) return;
      setState(() => _recordsFuture = _loadRecords());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance saved on this device.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save attendance: $error')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _dateLabel(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) {
    final present = _statuses.values.where((value) => value == 'present').length;
    final absent = _statuses.values.where((value) => value == 'absent').length;
    final leave = _statuses.values.where((value) => value == 'leave').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Attendance')),
      body: FutureBuilder<List<QueryRow>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Could not load attendance: ${snapshot.error}'),
              ),
            );
          }
          final records = snapshot.data ?? const <QueryRow>[];
          return Column(
            children: [
              Card(
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: 'Previous day',
                        onPressed: () => _changeDate(
                          _selectedDate.subtract(const Duration(days: 1)),
                        ),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: TextButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.calendar_month_outlined),
                          label: Text(_dateLabel(_selectedDate)),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next day',
                        onPressed: () => _changeDate(
                          _selectedDate.add(const Duration(days: 1)),
                        ),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _CountTile(label: 'Present', count: present),
                    const SizedBox(width: 8),
                    _CountTile(label: 'Absent', count: absent),
                    const SizedBox(width: 8),
                    _CountTile(label: 'Leave', count: leave),
                  ],
                ),
              ),
              Expanded(
                child: records.isEmpty
                    ? const Center(
                        child: Text('No active students. Add students first.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                        itemCount: records.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final row = records[index];
                          final id = row.read<int>('student_id');
                          final status = _statuses[id];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    row.read<String>('full_name'),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Admission no. ${row.read<String>('admission_number')}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Wrap(
                                    spacing: 8,
                                    children: [
                                      _statusChoice(id, 'present', 'Present',
                                          Icons.check_circle_outline, status),
                                      _statusChoice(id, 'absent', 'Absent',
                                          Icons.cancel_outlined, status),
                                      _statusChoice(id, 'leave', 'Leave',
                                          Icons.event_busy_outlined, status),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(_saving ? 'Saving...' : 'Save attendance'),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChoice(
    int studentId,
    String value,
    String label,
    IconData icon,
    String? selected,
  ) =>
      ChoiceChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: selected == value,
        onSelected: (_) => setState(() => _statuses[studentId] = value),
      );
}

class _CountTile extends StatelessWidget {
  const _CountTile({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('$count', style: Theme.of(context).textTheme.titleLarge),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      );
}
