import 'package:drift/drift.dart' show QueryRow;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  static const _categories = <String>[
    'Rent',
    'Utilities',
    'Supplies',
    'Maintenance',
    'Transport',
    'Marketing',
    'Other',
  ];
  static const _methods = <String>[
    'Cash',
    'Bank transfer',
    'UPI',
    'Cheque',
    'Other',
  ];

  late Future<List<QueryRow>> _expensesFuture;
  late Future<Map<String, int>> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final database = ref.read(appDatabaseProvider);
    _expensesFuture = database.getExpenses();
    _summaryFuture = database.getExpenseSummary(month: DateTime.now());
  }

  String _money(int paise) => '₹${(paise / 100).toStringAsFixed(2)}';

  Future<void> _addExpense() async {
    final formKey = GlobalKey<FormState>();
    final description = TextEditingController();
    final amount = TextEditingController();
    final reference = TextEditingController();
    var category = _categories.first;
    var method = _methods.first;
    var spentAt = DateTime.now();
    var saving = false;

    try {
      final saved = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Record expense'),
            content: SizedBox(
              width: 440,
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: category,
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        items: _categories
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => category = value);
                                }
                              },
                      ),
                      TextFormField(
                        controller: description,
                        autofocus: true,
                        maxLength: 240,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'e.g. Electricity bill for October',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) {
                            return 'Enter a description';
                          }
                          if (text.length > 240) {
                            return 'Maximum 240 characters';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: amount,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration:
                            const InputDecoration(labelText: 'Amount (₹) *'),
                        validator: (value) {
                          final parsed = double.tryParse((value ?? '').trim());
                          if (parsed == null ||
                              !parsed.isFinite ||
                              parsed <= 0) {
                            return 'Enter an amount greater than zero';
                          }
                          if (parsed > 100000000) return 'Amount is too large';
                          return null;
                        },
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: method,
                        decoration:
                            const InputDecoration(labelText: 'Payment method'),
                        items: _methods
                            .map((value) => DropdownMenuItem(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                        onChanged: saving
                            ? null
                            : (value) {
                                if (value != null) {
                                  setDialogState(() => method = value);
                                }
                              },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Expense date'),
                        subtitle: Text(
                          '${spentAt.day.toString().padLeft(2, '0')}/${spentAt.month.toString().padLeft(2, '0')}/${spentAt.year}',
                        ),
                        trailing: const Icon(Icons.calendar_month_outlined),
                        onTap: saving
                            ? null
                            : () async {
                                final picked = await showDatePicker(
                                  context: dialogContext,
                                  initialDate: spentAt,
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  setDialogState(() => spentAt = picked);
                                }
                              },
                      ),
                      TextFormField(
                        controller: reference,
                        maxLength: 120,
                        decoration: const InputDecoration(
                          labelText: 'Reference (optional)',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: saving
                    ? null
                    : () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: saving
                    ? null
                    : () async {
                        if (!formKey.currentState!.validate()) return;
                        setDialogState(() => saving = true);
                        try {
                          final parsed = double.parse(amount.text.trim());
                          await ref.read(appDatabaseProvider).recordExpense(
                                category: category,
                                description: description.text,
                                amountPaise: (parsed * 100).round(),
                                paymentMethod: method,
                                spentAt: spentAt,
                                reference: reference.text,
                              );
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(true);
                          }
                        } catch (error) {
                          setDialogState(() => saving = false);
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                  content:
                                      Text('Could not save expense: $error')),
                            );
                          }
                        }
                      },
                child: Text(saving ? 'Saving…' : 'Save expense'),
              ),
            ],
          ),
        ),
      );
      if (saved == true && mounted) {
        setState(_reload);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Expense saved on this device')),
        );
      }
    } finally {
      description.dispose();
      amount.dispose();
      reference.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Expense tracking')),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _addExpense,
          icon: const Icon(Icons.add),
          label: const Text('Add expense'),
        ),
        body: RefreshIndicator(
          onRefresh: () async => setState(_reload),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            children: [
              FutureBuilder<Map<String, int>>(
                future: _summaryFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Card(
                      child: ListTile(
                        leading: Icon(Icons.error_outline),
                        title: Text('Monthly summary unavailable'),
                      ),
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: LinearProgressIndicator(),
                      ),
                    );
                  }
                  final summary = snapshot.data!;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This month · ${DateTime.now().month}/${DateTime.now().year}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _money(summary['totalPaise'] ?? 0),
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text('${summary['count'] ?? 0} recorded expenses'),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text('Expense history',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              FutureBuilder<List<QueryRow>>(
                future: _expensesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text('Could not load expenses: ${snapshot.error}');
                  }
                  final rows = snapshot.data ?? [];
                  if (rows.isEmpty) {
                    return const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No expenses recorded yet. Add the first expense to start tracking institute costs.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return Card(
                    clipBehavior: Clip.antiAlias,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rows.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final row = rows[index];
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          row.read<int>('spent_at'),
                        );
                        final reference = row.read<String?>('reference');
                        final dateText =
                            '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt_long_outlined),
                          ),
                          title: Text(row.read<String>('description')),
                          subtitle: Text(
                            '${row.read<String>('category')} · $dateText · ${row.read<String>('payment_method')}'
                            '${reference == null || reference.isEmpty ? '' : '\nRef: $reference'}',
                          ),
                          isThreeLine:
                              reference != null && reference.isNotEmpty,
                          trailing: Text(
                            _money(row.read<int>('amount_paise')),
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
}
