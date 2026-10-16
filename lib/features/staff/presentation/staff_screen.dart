import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';

class StaffScreen extends ConsumerStatefulWidget {
  const StaffScreen({super.key});

  @override
  ConsumerState<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends ConsumerState<StaffScreen> {
  final _searchController = TextEditingController();
  bool _showInactive = false;
  late Future<List<QueryRow>> _staffFuture;

  @override
  void initState() {
    super.initState();
    _staffFuture = _loadStaff();
    _searchController.addListener(() => setState(() {}));
  }

  Future<List<QueryRow>> _loadStaff() =>
      ref.read(appDatabaseProvider).getStaffRecords(includeInactive: _showInactive);

  void _reload() {
    setState(() => _staffFuture = _loadStaff());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _money(int paise) => '₹${(paise / 100).toStringAsFixed(2)}';

  Future<void> _editStaff([QueryRow? record]) async {
    final name = TextEditingController(
      text: record?.read<String>('full_name') ?? '',
    );
    final role = TextEditingController(
      text: record?.read<String>('role') ?? '',
    );
    final phone = TextEditingController(
      text: record?.read<String?>('phone') ?? '',
    );
    final email = TextEditingController(
      text: record?.read<String?>('email') ?? '',
    );
    final salary = TextEditingController(
      text: record == null
          ? ''
          : (record.read<int>('monthly_salary_paise') / 100).toStringAsFixed(2),
    );
    final formKey = GlobalKey<FormState>();
    var saving = false;

    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(record == null ? 'Add staff member' : 'Edit staff member'),
            content: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: name,
                        autofocus: true,
                        maxLength: 100,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(labelText: 'Full name *'),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Enter the staff member name';
                          }
                          if (text.length > 100) {
                            return 'Maximum 100 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: role,
                        maxLength: 80,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Role / designation *',
                          hintText: 'e.g. Teacher, Accountant',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Enter a role';
                          }
                          if (text.length > 80) {
                            return 'Maximum 80 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phone,
                        maxLength: 30,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone (optional)'),
                      ),
                      TextFormField(
                        controller: email,
                        maxLength: 120,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(labelText: 'Email (optional)'),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isNotEmpty && !text.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: salary,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Monthly salary (₹)',
                          helperText: 'Optional. Enter 0 if not set.',
                        ),
                        validator: (value) {
                          final amount = double.tryParse((value ?? '').trim().isEmpty
                              ? '0'
                              : value!.trim());
                          if (amount == null || !amount.isFinite || amount < 0) {
                            return 'Enter a valid non-negative amount';
                          }
                          if (amount > 100000000) {
                            return 'Amount is too large';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving ? null : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) {
                          return;
                        }
                        setDialogState(() => saving = true);
                        try {
                          final parsedSalary = double.tryParse(
                                salary.text.trim().isEmpty ? '0' : salary.text.trim(),
                              ) ??
                              0;
                          await ref.read(appDatabaseProvider).saveStaff(
                                id: record?.read<int>('id'),
                                fullName: name.text,
                                role: role.text,
                                phone: phone.text,
                                email: email.text,
                                monthlySalaryPaise: (parsedSalary * 100).round(),
                              );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                          _reload();
                          if (mounted) {
                            ScaffoldMessenger.of(this.context).showSnackBar(
                              SnackBar(
                                content: Text(record == null
                                    ? 'Staff member saved on this device'
                                    : 'Staff details updated'),
                              ),
                            );
                          }
                        } catch (error) {
                          setDialogState(() => saving = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(content: Text('Could not save staff member: $error')),
                            );
                          }
                        }
                      },
                child: Text(saving ? 'Saving…' : 'Save'),
              ),
            ],
          ),
        ),
      );
    } finally {
      name.dispose();
      role.dispose();
      phone.dispose();
      email.dispose();
      salary.dispose();
    }
  }

  Future<void> _setActive(QueryRow record, bool active) async {
    try {
      await ref.read(appDatabaseProvider).setStaffActive(
            record.read<int>('id'),
            isActive: active,
          );
      _reload();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(active ? 'Staff member reactivated' : 'Staff member deactivated')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update staff status: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Staff management')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _editStaff(),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add staff'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search staff',
                  hintText: 'Name, role, phone, or email',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(Icons.clear),
                          tooltip: 'Clear search',
                        ),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            SwitchListTile(
              value: _showInactive,
              title: const Text('Show inactive staff'),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              onChanged: (value) {
                setState(() {
                  _showInactive = value;
                  _staffFuture = _loadStaff();
                });
              },
            ),
            Expanded(
              child: FutureBuilder<List<QueryRow>>(
                future: _staffFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text('Could not load staff: ${snapshot.error}'),
                      ),
                    );
                  }
                  final query = _searchController.text.trim().toLowerCase();
                  final records = (snapshot.data ?? []).where((row) {
                    final values = [
                      row.read<String>('full_name'),
                      row.read<String>('role'),
                      row.read<String?>('phone') ?? '',
                      row.read<String?>('email') ?? '',
                    ];
                    return values.any((value) => value.toLowerCase().contains(query));
                  }).toList();
                  if (records.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          query.isNotEmpty
                              ? 'No staff match “$query”.'
                              : _showInactive
                                  ? 'No staff records found.'
                                  : 'No staff yet. Add the first staff member.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                    itemCount: records.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      final active = record.read<int>('is_active') == 1;
                      final phone = record.read<String?>('phone');
                      final email = record.read<String?>('email');
                      final contacts = [
                        if (phone != null && phone.isNotEmpty) phone,
                        if (email != null && email.isNotEmpty) email,
                      ].join(' • ');
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(active ? Icons.person_outline : Icons.person_off_outlined),
                        ),
                        title: Text(record.read<String>('full_name')),
                        subtitle: Text(
                          '${record.read<String>('role')}'
                          '${contacts.isEmpty ? '' : '\n$contacts'}'
                          '\nMonthly salary: ${_money(record.read<int>('monthly_salary_paise'))}'
                          '${active ? '' : '\nInactive'}',
                        ),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') {
                              _editStaff(record);
                            } else {
                              _setActive(record, action == 'activate');
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value: active ? 'deactivate' : 'activate',
                              child: Text(active ? 'Deactivate' : 'Reactivate'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
}
