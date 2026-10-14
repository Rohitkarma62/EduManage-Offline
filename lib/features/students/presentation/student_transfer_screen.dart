import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../classes/providers/class_providers.dart';
import '../providers/student_providers.dart';

class StudentTransferScreen extends ConsumerStatefulWidget {
  const StudentTransferScreen({super.key, required this.studentId});

  final int studentId;

  @override
  ConsumerState<StudentTransferScreen> createState() =>
      _StudentTransferScreenState();
}

class _StudentTransferScreenState extends ConsumerState<StudentTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reason = TextEditingController();
  int? _classId;
  int? _batchId;
  DateTime? _effectiveFrom;
  DateTime? _currentStart;
  int? _currentClassId;
  int? _currentBatchId;
  String? _placementError;
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  DateTime get _today => DateUtils.dateOnly(DateTime.now());
  DateTime? get _minimumDate => _currentStart == null
      ? DateTime(2000)
      : DateUtils.dateOnly(_currentStart!).add(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _loadAssignment();
  }

  Future<void> _loadAssignment() async {
    try {
      final repository = ref.read(studentRepositoryProvider);
      final student = await repository.getStudent(widget.studentId);
      if (student == null) throw StateError('Student not found');
      final current = await repository.getCurrentAssignment(widget.studentId);
      if (!mounted) return;
      setState(() {
        _classId = current?.classId ?? student.classId;
        _batchId = current?.batchId;
        _currentClassId = current?.classId ?? student.classId;
        _currentBatchId = current?.batchId;
        _currentStart = current?.effectiveFrom;
        final minDate = _minimumDate!;
        _effectiveFrom = minDate.isAfter(_today) ? null : _today;
        _loading = false;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _loadError = error.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final minimum = _minimumDate!;
    if (minimum.isAfter(_today)) return;
    final selected = await showDatePicker(
      context: context,
      initialDate: _effectiveFrom ?? _today,
      firstDate: minimum,
      lastDate: _today,
      helpText: 'Select transfer effective date',
    );
    if (selected != null && mounted) {
      setState(() => _effectiveFrom = DateUtils.dateOnly(selected));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final effectiveFrom = _effectiveFrom;
    final classId = _classId;
    if (effectiveFrom == null || classId == null) return;
    if (classId == _currentClassId && _batchId == _currentBatchId) {
      setState(() => _placementError =
          'Choose a different class or batch before saving a transfer.');
      return;
    }

    setState(() {
      _placementError = null;
      _saving = true;
    });
    try {
      await ref.read(studentRepositoryProvider).transferStudent(
            studentId: widget.studentId,
            classId: classId,
            batchId: _batchId,
            effectiveFrom: effectiveFrom,
            reason: _reason.text.trim(),
          );
      ref.invalidate(studentsProvider);
      ref.invalidate(studentAssignmentHistoryProvider(widget.studentId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student transfer saved')),
        );
        context.pop(true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not transfer student: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final minimum = _minimumDate;
    final dateUnavailable = minimum != null && minimum.isAfter(_today);
    return Scaffold(
      appBar: AppBar(title: const Text('Transfer student')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? Center(child: Text('Could not load student: $_loadError'))
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Choose the new class or batch and record why the placement is changing.',
                      ),
                      const SizedBox(height: 20),
                      ref.watch(activeClassesProvider).when(
                            loading: () => const LinearProgressIndicator(),
                            error: (error, stack) => Text(
                              'Could not load classes: $error',
                            ),
                            data: (classes) => DropdownButtonFormField<int>(
                              initialValue:
                                  classes.any((item) => item.id == _classId)
                                      ? _classId
                                      : null,
                              decoration: const InputDecoration(
                                labelText: 'New class *',
                                border: OutlineInputBorder(),
                              ),
                              items: classes
                                  .map((item) => DropdownMenuItem<int>(
                                        value: item.id,
                                        child: Text(
                                          '${item.name} • ${item.academicYear}',
                                        ),
                                      ))
                                  .toList(),
                              validator: (value) =>
                                  value == null ? 'Select a class' : null,
                              onChanged: _saving
                                  ? null
                                  : (value) => setState(() {
                                        _classId = value;
                                        _batchId = null;
                                        _placementError = null;
                                      }),
                            ),
                          ),
                      const SizedBox(height: 16),
                      if (_classId != null)
                        ref.watch(classBatchesProvider(_classId!)).when(
                              loading: () => const LinearProgressIndicator(),
                              error: (error, stack) => Text(
                                'Could not load batches: $error',
                              ),
                              data: (batches) {
                                final available = batches
                                    .where((batch) => batch.isActive)
                                    .toList();
                                return DropdownButtonFormField<int?>(
                                  initialValue: available
                                          .any((batch) => batch.id == _batchId)
                                      ? _batchId
                                      : null,
                                  decoration: const InputDecoration(
                                    labelText: 'Batch (optional)',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text('No specific batch'),
                                    ),
                                    ...available.map(
                                      (batch) => DropdownMenuItem<int?>(
                                        value: batch.id,
                                        child: Text(batch.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: _saving
                                      ? null
                                      : (value) => setState(() {
                                            _batchId = value;
                                            _placementError = null;
                                          }),
                                );
                              },
                            ),
                      if (_placementError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            _placementError!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed:
                            _saving || dateUnavailable ? null : _chooseDate,
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          _effectiveFrom == null
                              ? 'Choose effective date *'
                              : 'Effective date: ${_formatDate(_effectiveFrom!)}',
                        ),
                      ),
                      if (dateUnavailable)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'This student’s current assignment started today. Transfers can be scheduled from tomorrow; come back then.',
                          ),
                        ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _reason,
                        maxLength: 240,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Transfer reason *',
                          hintText: 'For example, promoted to the next class',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          final reason = value?.trim() ?? '';
                          if (reason.isEmpty) return 'Enter a transfer reason';
                          if (reason.length > 240) {
                            return 'Maximum 240 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        onPressed:
                            _saving || dateUnavailable || _effectiveFrom == null
                                ? null
                                : _save,
                        icon: const Icon(Icons.check),
                        label: Text(_saving ? 'Saving…' : 'Save transfer'),
                      ),
                    ],
                  ),
                ),
    );
  }

  String _formatDate(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
