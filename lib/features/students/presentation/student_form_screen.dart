import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/student_providers.dart';
import '../../classes/providers/class_providers.dart';

class StudentFormScreen extends ConsumerStatefulWidget {
  const StudentFormScreen({super.key, this.studentId});

  final int? studentId;

  @override
  ConsumerState<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends ConsumerState<StudentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _admission = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _guardian = TextEditingController();
  int? _classId;\n  bool _saving = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.studentId != null) {
      _loading = true;
      _loadStudent();
    }
  }

  Future<void> _loadStudent() async {
    try {
      final student = await ref
          .read(studentRepositoryProvider)
          .getStudent(widget.studentId!);
      if (!mounted) return;
      if (student == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student not found')),
        );
        context.pop();
        return;
      }
      _admission.text = student.admissionNumber;
      _name.text = student.fullName;
      _phone.text = student.phone ?? '';
      _guardian.text = student.guardianName ?? '';\n      _classId = student.classId;
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load student: $error')),
        );
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _admission.dispose();
    _name.dispose();
    _phone.dispose();
    _guardian.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repository = ref.read(studentRepositoryProvider);
      final admissionNumber = _admission.text.trim().toUpperCase();
      final alreadyExists = await repository.admissionNumberExists(
        admissionNumber: admissionNumber,
        excludingId: widget.studentId,
      );
      if (alreadyExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Admission number already exists'),
            ),
          );
        }
        return;
      }

      await repository.saveStudent(
        id: widget.studentId,
        admissionNumber: admissionNumber,
        fullName: _name.text.trim(),
        phone: _phone.text,
        guardianName: _guardian.text,
      );
      ref.invalidate(studentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.studentId == null
                ? 'Student saved on this device'
                : 'Student changes saved'),
          ),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save student: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title:
              Text(widget.studentId == null ? 'Add student' : 'Edit student'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextFormField(
                      controller: _admission,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 40,
                      decoration: const InputDecoration(
                        labelText: 'Admission number *',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter an admission number'
                          : v.trim().length > 40
                              ? 'Maximum 40 characters'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 120,
                      decoration:
                          const InputDecoration(labelText: 'Student name *'),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'Enter the student name'
                          : v.trim().length > 120
                              ? 'Maximum 120 characters'
                              : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      maxLength: 20,
                      decoration:
                          const InputDecoration(labelText: 'Phone (optional)'),
                      validator: (v) {
                        final p = v?.trim() ?? '';
                        return p.isNotEmpty && (p.length < 7 || p.length > 20)
                            ? 'Phone must be 7 to 20 characters'
                            : null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _guardian,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 120,
                      decoration: const InputDecoration(
                        labelText: 'Parent/guardian (optional)',
                      ),
                      validator: (v) => (v?.trim().length ?? 0) > 120
                          ? 'Maximum 120 characters'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    ref.watch(allClassesProvider).when(
                          loading: () => const LinearProgressIndicator(),
                          error: (_, __) => const Text(
                            'Class list unavailable. Student can remain unassigned.',
                          ),
                          data: (classes) => DropdownButtonFormField<int>(
                            value: classes.any((record) => record.id == _classId)
                                ? _classId
                                : null,
                            decoration: const InputDecoration(
                              labelText: 'Class or batch (optional)',
                              border: OutlineInputBorder(),
                            ),
                            items: [
                              const DropdownMenuItem<int>(
                                value: null,
                                child: Text('Unassigned'),
                              ),
                              ...classes.map(
                                (record) => DropdownMenuItem<int>(
                                  value: record.id,
                                  child: Text(
                                    '${record.name} • ${record.academicYear}${record.isActive ? '' : ' (inactive)'}',
                                  ),
                                ),
                              ),
                            ],
                            onChanged: _saving
                                ? null
                                : (value) => setState(() => _classId = value),
                          ),
                        ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving
                          ? 'Saving…'
                          : widget.studentId == null
                              ? 'Save student'
                              : 'Save changes'),
                    ),
                  ],
                ),
              ),
      );
}
