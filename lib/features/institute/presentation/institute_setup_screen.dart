import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/institute_providers.dart';

class InstituteSetupScreen extends ConsumerStatefulWidget {
  const InstituteSetupScreen({super.key});

  @override
  ConsumerState<InstituteSetupScreen> createState() =>
      _InstituteSetupScreenState();
}

class _InstituteSetupScreenState extends ConsumerState<InstituteSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadInstitute();
  }

  Future<void> _loadInstitute() async {
    try {
      final institute = await ref.read(instituteRepositoryProvider).getInstitute();
      if (!mounted) return;
      if (institute != null) {
        _nameController.text = institute.name;
        _yearController.text = institute.academicYear;
        _phoneController.text = institute.phone ?? '';
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not load institute details from local storage.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ref.read(instituteRepositoryProvider).saveInstitute(
            name: _nameController.text,
            academicYear: _yearController.text,
            phone: _phoneController.text,
          );
      ref.invalidate(instituteProvider);
      if (!mounted) return;
      _showMessage('Institute details saved on this device.');
      context.go('/');
    } catch (_) {
      if (mounted) _showMessage('Save failed. Your details were not confirmed.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Institute setup')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Your institute, stored locally',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter the basic details to set up this device. '
                    'No internet connection is required.',
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Institute name *',
                            hintText: 'e.g. North Star Institute',
                          ),
                          validator: (value) {
                            final name = value?.trim() ?? '';
                            if (name.isEmpty) return 'Institute name is required';
                            if (name.length > 120) {
                              return 'Use 120 characters or fewer';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _yearController,
                          decoration: const InputDecoration(
                            labelText: 'Academic year *',
                            hintText: 'e.g. 2026-2027',
                          ),
                          validator: (value) {
                            final year = value?.trim() ?? '';
                            if (year.length < 4 || year.length > 20) {
                              return 'Enter an academic year (4 to 20 characters)';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Phone (optional)',
                            hintText: 'Contact number',
                          ),
                          validator: (value) {
                            final phone = value?.trim() ?? '';
                            if (phone.isNotEmpty &&
                                (phone.length < 7 || phone.length > 20)) {
                              return 'Phone must be 7 to 20 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _saving ? null : _save,
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.save_outlined),
                            label: Text(_saving ? 'Saving...' : 'Save institute'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
