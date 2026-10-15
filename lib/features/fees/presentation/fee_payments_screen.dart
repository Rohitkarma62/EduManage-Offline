import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../students/providers/student_providers.dart';

class FeePaymentsScreen extends ConsumerWidget {
  const FeePaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final students = ref.watch(studentsProvider(''));
    return Scaffold(
      appBar: AppBar(title: const Text('Fee payments')),
      body: students.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Could not load students: ' + error.toString())),
        data: (records) {
          final active = records.where((student) => student.isActive).toList();
          if (active.isEmpty) {
            return const Center(child: Text('No active students found. Add or reactivate a student first.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: active.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final student = active[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.account_balance_wallet_outlined)),
                title: Text(student.fullName),
                subtitle: Text('Admission no. ' + student.admissionNumber),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/fees/' + student.id.toString()),
              );
            },
          );
        },
      ),
    );
  }
}

class StudentFeesScreen extends ConsumerStatefulWidget {
  const StudentFeesScreen({required this.studentId, super.key});
  final int studentId;

  @override
  ConsumerState<StudentFeesScreen> createState() => _StudentFeesScreenState();
}

class _StudentFeesScreenState extends ConsumerState<StudentFeesScreen> {
  late Future<_FeeData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_FeeData> _load() async {
    final db = ref.read(appDatabaseProvider);
    final student = await db.getStudent(widget.studentId);
    if (student == null) throw StateError('Student record not found.');
    final assignment = await db.getCurrentStudentAssignment(widget.studentId);
    final charges = await db.getFeeChargesForStudent(widget.studentId);
    final summaries = <_ChargeSummary>[];
    for (final charge in charges) {
      summaries.add(_ChargeSummary(
        charge,
        await db.getTotalPaidForCharge(charge.id),
        await db.getFeePaymentsForCharge(charge.id),
      ));
    }
    return _FeeData(student, assignment, summaries);
  }

  void _refresh() => setState(() => _future = _load());

  Future<void> _addCharge(_FeeData data) async {
    if (data.assignment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assign the student to a class before adding a fee.')),
      );
      return;
    }
    final input = await showDialog<_ChargeInput>(
      context: context,
      builder: (_) => const _ChargeDialog(),
    );
    if (input == null || !mounted) return;
    try {
      await ref.read(appDatabaseProvider).createFeeCharge(
        studentId: data.student.id,
        assignmentId: data.assignment!.id,
        title: input.title,
        amountPaise: input.amountPaise,
        periodStart: input.start,
        periodEnd: input.end,
        dueDate: input.due,
      );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fee charge created.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create fee charge: ' + error.toString())),
        );
      }
    }
  }

  Future<void> _addPayment(_ChargeSummary summary) async {
    final balance = summary.charge.amountPaise - summary.paid;
    if (balance <= 0) return;
    final input = await showDialog<_PaymentInput>(
      context: context,
      builder: (_) => _PaymentDialog(balance: balance),
    );
    if (input == null || !mounted) return;
    try {
      await ref.read(appDatabaseProvider).recordFeePayment(
        feeChargeId: summary.charge.id,
        amountPaise: input.amountPaise,
        method: input.method,
        reference: input.reference,
        idempotencyKey: const Uuid().v4(),
        receivedAt: DateTime.now(),
      );
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully.')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not record payment: ' + error.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Student fees')),
    body: FutureBuilder<_FeeData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(child: Text('Could not load fees: ' + snapshot.error.toString()));
        }
        final data = snapshot.data!;
        final total = data.charges.fold<int>(0, (sum, item) => sum + item.charge.amountPaise);
        final paid = data.charges.fold<int>(0, (sum, item) => sum + item.paid);
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(data.student.fullName, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('Admission no. ' + data.student.admissionNumber),
                  const SizedBox(height: 16),
                  Row(children: [
                    _Summary(label: 'Total fees', amount: total),
                    _Summary(label: 'Paid', amount: paid),
                    _Summary(label: 'Balance', amount: total - paid),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => _addCharge(data),
              icon: const Icon(Icons.add),
              label: const Text('Add fee charge'),
            ),
            if (data.assignment == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('No current class assignment. Assign a class before creating a new fee charge.'),
              ),
            const SizedBox(height: 16),
            Text('Fee charges', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            if (data.charges.isEmpty)
              const Card(child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No fee charges yet. Add a charge to track payments.'),
              )),
            ...data.charges.map((item) {
              final balance = item.charge.amountPaise - item.paid;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.charge.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(_date(item.charge.periodStart) + ' – ' + _date(item.charge.periodEnd) + ' (end exclusive)'),
                    Text('Due ' + _date(item.charge.dueDate)),
                    const SizedBox(height: 10),
                    Text('Fee: ' + _money(item.charge.amountPaise)),
                    Text('Paid: ' + _money(item.paid)),
                    Text(
                      'Balance: ' + _money(balance),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: balance > 0 ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    if (balance > 0)
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.tonalIcon(
                          onPressed: () => _addPayment(item),
                          icon: const Icon(Icons.payments_outlined),
                          label: const Text('Record payment'),
                        ),
                      ),
                    if (item.payments.isNotEmpty) ...[
                      const Divider(height: 24),
                      Text('Payment history', style: Theme.of(context).textTheme.titleSmall),
                      ...item.payments.map((payment) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.receipt_long_outlined),
                        title: Text(_money(payment.amountPaise)),
                        subtitle: Text(
                          _method(payment.method) + ' • ' + _date(payment.receivedAt) +
                          (payment.reference == null ? '' : ' • Ref: ' + payment.reference!),
                        ),
                      )),
                    ],
                  ]),
                ),
              );
            }),
          ],
        );
      },
    ),
  );
}

class _ChargeDialog extends StatefulWidget {
  const _ChargeDialog();
  @override
  State<_ChargeDialog> createState() => _ChargeDialogState();
}

class _ChargeDialogState extends State<_ChargeDialog> {
  final _key = GlobalKey<FormState>();
  final _title = TextEditingController(text: 'Tuition fee');
  final _amount = TextEditingController();
  final _now = DateTime.now();
  late DateTime _start = DateTime(_now.year, _now.month);
  late DateTime _end = DateTime(_now.year, _now.month + 1);
  late DateTime _due = DateTime(_now.year, _now.month, _now.day).add(const Duration(days: 7));

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _pick(String which) async {
    final initial = which == 'start' ? _start : which == 'end' ? _end : _due;
    final value = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (value == null) return;
    setState(() {
      if (which == 'start') _start = value;
      if (which == 'end') _end = value;
      if (which == 'due') _due = value;
    });
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Add fee charge'),
    content: SingleChildScrollView(
      child: Form(
        key: _key,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _title,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Fee title'),
            validator: (value) => value == null || value.trim().isEmpty ? 'Enter a fee title' : null,
          ),
          TextFormField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount (₹)'),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || !amount.isFinite || amount <= 0) return 'Enter an amount greater than zero';
              if (amount > 99999999) return 'Amount is too large';
              return null;
            },
          ),
          _DateTile(label: 'Period starts', date: _start, onTap: () => _pick('start')),
          _DateTile(label: 'Period ends (exclusive)', date: _end, onTap: () => _pick('end')),
          _DateTile(label: 'Due date', date: _due, onTap: () => _pick('due')),
          if (!_end.isAfter(_start))
            const Text('End date must be after start date.', style: TextStyle(color: Colors.red)),
        ]),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        onPressed: () {
          if (!_key.currentState!.validate() || !_end.isAfter(_start)) return;
          Navigator.pop(context, _ChargeInput(
            _title.text.trim(),
            (double.parse(_amount.text.trim()) * 100).round(),
            _start, _end, _due,
          ));
        },
        child: const Text('Create charge'),
      ),
    ],
  );
}

class _PaymentDialog extends StatefulWidget {
  const _PaymentDialog({required this.balance});
  final int balance;
  @override
  State<_PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<_PaymentDialog> {
  final _key = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  String _methodValue = 'cash';

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Record payment'),
    content: Form(
      key: _key,
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Align(alignment: Alignment.centerLeft, child: Text('Outstanding: ' + _money(widget.balance))),
          const SizedBox(height: 12),
          TextFormField(
            controller: _amount,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Amount received (₹)'),
            validator: (value) {
              final amount = double.tryParse(value?.trim() ?? '');
              if (amount == null || !amount.isFinite || amount <= 0) return 'Enter an amount greater than zero';
              if ((amount * 100).round() > widget.balance) return 'Cannot exceed outstanding balance';
              return null;
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _methodValue,
            decoration: const InputDecoration(labelText: 'Payment method'),
            items: const [
              DropdownMenuItem(value: 'cash', child: Text('Cash')),
              DropdownMenuItem(value: 'upi', child: Text('UPI')),
              DropdownMenuItem(value: 'bank_transfer', child: Text('Bank transfer')),
              DropdownMenuItem(value: 'card', child: Text('Card')),
              DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) { if (value != null) setState(() => _methodValue = value); },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _reference,
            maxLength: 120,
            decoration: const InputDecoration(labelText: 'Reference (optional)'),
          ),
        ]),
      ),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(
        onPressed: () {
          if (!_key.currentState!.validate()) return;
          Navigator.pop(context, _PaymentInput(
            (double.parse(_amount.text.trim()) * 100).round(),
            _methodValue,
            _reference.text.trim(),
          ));
        },
        child: const Text('Save payment'),
      ),
    ],
  );
}

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label, required this.date, required this.onTap});
  final String label;
  final DateTime date;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(_date(date)),
    trailing: const Icon(Icons.calendar_month_outlined),
    onTap: onTap,
  );
}

class _Summary extends StatelessWidget {
  const _Summary({required this.label, required this.amount});
  final String label;
  final int amount;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: Theme.of(context).textTheme.bodySmall),
      const SizedBox(height: 4),
      Text(_money(amount), style: Theme.of(context).textTheme.titleSmall),
    ]),
  );
}

class _FeeData {
  const _FeeData(this.student, this.assignment, this.charges);
  final Student student;
  final StudentAssignment? assignment;
  final List<_ChargeSummary> charges;
}

class _ChargeSummary {
  const _ChargeSummary(this.charge, this.paid, this.payments);
  final FeeCharge charge;
  final int paid;
  final List<FeePaymentRecord> payments;
}

class _ChargeInput {
  const _ChargeInput(this.title, this.amountPaise, this.start, this.end, this.due);
  final String title;
  final int amountPaise;
  final DateTime start;
  final DateTime end;
  final DateTime due;
}

class _PaymentInput {
  const _PaymentInput(this.amountPaise, this.method, this.reference);
  final int amountPaise;
  final String method;
  final String reference;
}

String _money(int paise) => '₹' + (paise / 100).toStringAsFixed(2);
String _date(DateTime value) =>
    value.day.toString().padLeft(2, '0') + '/' +
    value.month.toString().padLeft(2, '0') + '/' + value.year.toString();
String _method(String value) => switch (value) {
  'cash' => 'Cash',
  'upi' => 'UPI',
  'bank_transfer' => 'Bank transfer',
  'card' => 'Card',
  'cheque' => 'Cheque',
  _ => 'Other',
};
