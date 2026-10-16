import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';

class StaffSalaryPaymentsScreen extends ConsumerStatefulWidget {
  const StaffSalaryPaymentsScreen({super.key});

  @override
  ConsumerState<StaffSalaryPaymentsScreen> createState() => _StaffSalaryPaymentsScreenState();
}

class _StaffSalaryPaymentsScreenState extends ConsumerState<StaffSalaryPaymentsScreen> {
  late Future<List<QueryRow>> _paymentsFuture;
  late Future<List<QueryRow>> _staffFuture;
  int? _filterStaffId;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final db = ref.read(appDatabaseProvider);
    _paymentsFuture = db.getStaffSalaryPayments(staffId: _filterStaffId);
    _staffFuture = db.getStaffRecords();
  }

  String _money(int paise) => '₹${(paise / 100).toStringAsFixed(2)}';

  Future<void> _addPayment(List<QueryRow> staff) async {
    if (staff.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add an active staff member first.')),
      );
      return;
    }
    int staffId = staff.first.read<int>('id');
    String method = 'Cash';
    DateTime paidAt = DateTime.now();
    final amount = TextEditingController();
    final reference = TextEditingController();
    final notes = TextEditingController();
    final formKey = GlobalKey<FormState>();
    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Record salary payment'),
            content: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<int>(
                        value: staffId,
                        isExpanded: true,
                        decoration: const InputDecoration(labelText: 'Staff member'),
                        items: staff.map((row) => DropdownMenuItem<int>(
                          value: row.read<int>('id'),
                          child: Text(row.read<String>('full_name')),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) setDialogState(() => staffId = value);
                        },
                      ),
                      TextFormField(
                        controller: amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount paid (₹) *'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null || !parsed.isFinite || parsed <= 0 || parsed > 100000000) {
                            return 'Enter an amount greater than zero';
                          }
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        value: method,
                        decoration: const InputDecoration(labelText: 'Payment method'),
                        items: const ['Cash', 'Bank transfer', 'UPI', 'Cheque', 'Other']
                            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setDialogState(() => method = value);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Payment date'),
                        subtitle: Text('${paidAt.day}/${paidAt.month}/${paidAt.year}'),
                        trailing: const Icon(Icons.calendar_month),
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: dialogContext,
                            initialDate: paidAt,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (selected != null) setDialogState(() => paidAt = selected);
                        },
                      ),
                      TextFormField(controller: reference, maxLength: 120,
                        decoration: const InputDecoration(labelText: 'Reference (optional)')),
                      TextFormField(controller: notes, maxLength: 500, maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Notes (optional)')),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel')),
              FilledButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;
                  final rupees = double.parse(amount.text.trim());
                  try {
                    await ref.read(appDatabaseProvider).recordStaffSalaryPayment(
                      staffId: staffId,
                      amountPaise: (rupees * 100).round(),
                      paymentMethod: method,
                      paidAt: paidAt,
                      reference: reference.text,
                      notes: notes.text,
                    );
                    if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                  } catch (error) {
                    if (dialogContext.mounted) {
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        SnackBar(content: Text('Could not record payment: ${error}')),
                      );
                    }
                  }
                },
                child: const Text('Save payment'),
              ),
            ],
          ),
        ),
      );
      if (saved == true && mounted) {
        setState(_reload);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salary payment saved on this device')),
        );
      }
    } finally {
      amount.dispose();
      reference.dispose();
      notes.dispose();
    }
  }

  Future<void> _chooseMonth() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Choose a date in the month',
    );
    if (selected != null && mounted) {
      setState(() => _selectedMonth = DateTime(selected.year, selected.month));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Salary payment history')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () async {
        final staff = await _staffFuture;
        if (mounted) await _addPayment(staff);
      },
      icon: const Icon(Icons.payments_outlined),
      label: const Text('Record payment'),
    ),
    body: FutureBuilder<List<QueryRow>>(
      future: _staffFuture,
      builder: (context, staffSnapshot) {
        if (staffSnapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (staffSnapshot.hasError) {
          return Center(child: Text('Could not load staff: ${staffSnapshot.error}'));
        }
        final staff = staffSnapshot.data ?? [];
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      value: _filterStaffId,
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'Filter by staff',
                        border: OutlineInputBorder()),
                      items: [
                        const DropdownMenuItem<int?>(value: null, child: Text('All staff')),
                        ...staff.map((row) => DropdownMenuItem<int?>(
                          value: row.read<int>('id'),
                          child: Text(row.read<String>('full_name')),
                        )),
                      ],
                      onChanged: (value) => setState(() {
                        _filterStaffId = value;
                        _reload();
                      }),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(onPressed: _chooseMonth, tooltip: 'Choose month for summary',
                    icon: const Icon(Icons.calendar_month)),
                ],
              ),
            ),
            Text('Monthly summary: ${_monthLabel(_selectedMonth)}',
              style: Theme.of(context).textTheme.titleSmall),
            Expanded(
              child: FutureBuilder<List<QueryRow>>(
                future: _paymentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Could not load payments: ${snapshot.error}'));
                  }
                  final payments = snapshot.data ?? [];
                  if (payments.isEmpty) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No salary payments recorded yet. Use “Record payment” to add the first entry.',
                        textAlign: TextAlign.center),
                    ));
                  }
                  final monthPayments = payments.where((row) {
                    final date = DateTime.fromMillisecondsSinceEpoch(row.read<int>('paid_at'));
                    return date.year == _selectedMonth.year && date.month == _selectedMonth.month;
                  }).toList();
                  final total = monthPayments.fold<int>(0,
                    (sum, row) => sum + row.read<int>('amount_paise'));
                  return Column(
                    children: [
                      Card(
                        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        child: ListTile(
                          title: Text('Paid in ${_monthLabel(_selectedMonth)}'),
                          trailing: Text(_money(total),
                            style: Theme.of(context).textTheme.titleMedium),
                          subtitle: Text('${monthPayments.length} payment(s) in selected month'),
                        ),
                      ),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
                          itemCount: payments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final row = payments[index];
                            final date = DateTime.fromMillisecondsSinceEpoch(row.read<int>('paid_at'));
                            final reference = row.readNullable<String>('reference');
                            final notes = row.readNullable<String>('notes');
                            return ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.payments_outlined)),
                              title: Text(row.read<String>('staff_name')),
                              subtitle: Text(
                                '${date.day}/${date.month}/${date.year} • ${row.read<String>('payment_method')}'
                                '${reference == null || reference.isEmpty ? '' : '\nRef: $reference'}'
                                '${notes == null || notes.isEmpty ? '' : '\n$notes'}',
                              ),
                              isThreeLine: (reference?.isNotEmpty ?? false) || (notes?.isNotEmpty ?? false),
                              trailing: Text(_money(row.read<int>('amount_paise')),
                                style: Theme.of(context).textTheme.titleSmall),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );

  String _monthLabel(DateTime date) => '${_monthName(date.month)} ${date.year}';

  String _monthName(int month) => const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ][month - 1];
}
