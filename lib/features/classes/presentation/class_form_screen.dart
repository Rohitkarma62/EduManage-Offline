import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/class_providers.dart';

class ClassFormScreen extends ConsumerStatefulWidget {
  const ClassFormScreen({super.key, this.classId});
  final int? classId;

  @override
  ConsumerState<ClassFormScreen> createState() => _ClassFormScreenState();
}

class _ClassFormScreenState extends ConsumerState<ClassFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _year = TextEditingController();
  final _description = TextEditingController();
  bool _saving = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.classId != null) {
      _loading = true;
      _loadClass();
    }
  }

  Future<void> _loadClass() async {
    try {
      final record = await ref.read(classRepositoryProvider).getClass(widget.classId!);
      if (!mounted) {
        return;
      }
      if (record == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Class or batch not found')),
        );
        context.pop();
        return;
      }
      _name.text = record.name;
      _year.text = record.academicYear;
      _description.text = record.description ?? '';
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load class: $error')),
        );
        context.pop();
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _year.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(classRepositoryProvider);
      final name = _name.text.trim();
      final year = _year.text.trim();
      if (await repository.classExists(
        name: name,
        academicYear: year,
        excludingId: widget.classId,
      )) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('A class with this name already exists for this year')),
          );
        }
        return;
      }
      await repository.saveClass(
        id: widget.classId,
        name: name,
        academicYear: year,
        description: _description.text,
      );
      ref.invalidate(classesProvider);
      ref.invalidate(activeClassesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.classId == null ? 'Class saved on this device' : 'Class changes saved')),
        );
        context.pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save class: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.classId == null ? 'Add class or batch' : 'Edit class'),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 100,
                      decoration: const InputDecoration(
                        labelText: 'Class or batch name *',
                        hintText: 'e.g. Class 10 A, NEET Morning',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.isEmpty) {
                          return 'Enter a class or batch name';
                        }
                        if (text.length > 100) {
                          return 'Maximum 100 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _year,
                      maxLength: 20,
                      decoration: const InputDecoration(
                        labelText: 'Academic year *',
                        hintText: 'e.g. 2026-2027',
                      ),
                      validator: (value) {
                        final text = value?.trim() ?? '';
                        if (text.length < 4) {
                          return 'Enter a valid academic year';
                        }
                        if (text.length > 20) {
                          return 'Maximum 20 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _description,
                      maxLength: 240,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description (optional)'),
                      validator: (value) => (value?.trim().length ?? 0) > 240
                          ? 'Maximum 240 characters'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _saving ? null : _save,
                      child: Text(_saving ? 'Saving…' : widget.classId == null ? 'Save class' : 'Save changes'),
                    ),
                  ],
                ),
              ),
      );
}
