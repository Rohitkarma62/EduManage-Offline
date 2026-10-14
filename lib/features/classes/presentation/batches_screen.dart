import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';

import '../providers/class_providers.dart';

class BatchesScreen extends ConsumerWidget {
  const BatchesScreen({super.key, required this.classId});
  final int classId;

  Future<void> _saveBatch(
    BuildContext context,
    WidgetRef ref, {
    int? id,
    String name = '',
    String subject = '',
    String timing = '',
    String teacher = '',
    String fee = '',
  }) async {
    final key = GlobalKey<FormState>();
    final nameController = TextEditingController(text: name);
    final subjectController = TextEditingController(text: subject);
    final timingController = TextEditingController(text: timing);
    final teacherController = TextEditingController(text: teacher);
    final feeController = TextEditingController(text: fee);
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(id == null ? 'Add batch' : 'Edit batch'),
        content: SingleChildScrollView(
          child: Form(
            key: key,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  autofocus: true,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: 'Batch name *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a batch name'
                      : null,
                ),
                TextFormField(
                  controller: subjectController,
                  maxLength: 80,
                  decoration: const InputDecoration(labelText: 'Subject (optional)'),
                ),
                TextFormField(
                  controller: timingController,
                  maxLength: 100,
                  decoration: const InputDecoration(
                    labelText: 'Timing (optional)',
                    hintText: 'e.g. Mon-Wed-Fri, 4:00 PM',
                  ),
                ),
                TextFormField(
                  controller: teacherController,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Teacher (optional)'),
                ),
                TextFormField(
                  controller: feeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Monthly fee in ₹ (optional)'),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    if (input.isEmpty) return null;
                    final amount = double.tryParse(input);
                    if (amount == null || !amount.isFinite || amount < 0 ||
                        amount * 100 > 9000000000000000) {
                      return 'Enter a valid non-negative amount';
                    }
                    if ((amount * 100 - (amount * 100).round()).abs() > 0.000001) {
                      return 'Use at most 2 decimal places';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (!key.currentState!.validate()) return;
              final repository = ref.read(classRepositoryProvider);
              if (await repository.batchExists(
                classId: classId,
                name: nameController.text,
                excludingId: id,
              )) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('A batch with this name already exists in this class')),
                  );
                }
                return;
              }
              final feeText = feeController.text.trim();
              await repository.saveBatch(
                id: id,
                classId: classId,
                name: nameController.text,
                subject: subjectController.text,
                timing: timingController.text,
                teacherName: teacherController.text,
                monthlyFeePaise: feeText.isEmpty
                    ? null
                    : (double.parse(feeText) * 100).round(),
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext, true);
            },
            child: const Text('Save batch'),
          ),
        ],
      ),
    );
    nameController.dispose();
    subjectController.dispose();
    timingController.dispose();
    teacherController.dispose();
    feeController.dispose();
    if (saved == true) ref.invalidate(classBatchesProvider(classId));
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    ClassBatchSession batch,
    bool active,
  ) async {
    if (!active) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Archive batch?'),
          content: Text('“${batch.name}” will be archived. Its record will be retained for history.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Archive'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }
    await ref.read(classRepositoryProvider).setBatchActive(batch.id, isActive: active);
    ref.invalidate(classBatchesProvider(classId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = ref.watch(classDetailProvider(classId));
    final batches = ref.watch(classBatchesProvider(classId));
    return Scaffold(
      appBar: AppBar(title: const Text('Batches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _saveBatch(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add batch'),
      ),
      body: parent.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Could not load class: $error')),
        data: (classRecord) {
          if (classRecord == null) return const Center(child: Text('Class not found.'));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: ListTile(
                    leading: const Icon(Icons.class_outlined),
                    title: Text(classRecord.name),
                    subtitle: Text('Academic year ${classRecord.academicYear}'),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text('Batches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: batches.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Could not load batches: $error')),
                  data: (records) {
                    if (records.isEmpty) return const Center(child: Text('No batches in this class yet.'));
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                      itemCount: records.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final batch = records[index];
                        final fee = batch.monthlyFeePaise == null
                            ? 'Monthly fee not set'
                            : '₹${(batch.monthlyFeePaise! / 100).toStringAsFixed(2)} / month';
                        final details = [
                          if (batch.subject != null) batch.subject!,
                          if (batch.timing != null) batch.timing!,
                          if (batch.teacherName != null) batch.teacherName!,
                          fee,
                        ].join(' • ');
                        return ListTile(
                          leading: CircleAvatar(
                            child: Icon(batch.isActive ? Icons.groups_outlined : Icons.archive_outlined),
                          ),
                          title: Text(batch.name),
                          subtitle: Text('${batch.isActive ? '' : 'Archived • '}$details'),
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) async {
                              if (action == 'edit') {
                                await _saveBatch(
                                  context,
                                  ref,
                                  id: batch.id,
                                  name: batch.name,
                                  subject: batch.subject ?? '',
                                  timing: batch.timing ?? '',
                                  teacher: batch.teacherName ?? '',
                                  fee: batch.monthlyFeePaise == null
                                      ? ''
                                      : (batch.monthlyFeePaise! / 100).toStringAsFixed(2),
                                );
                              } else {
                                await _setActive(context, ref, batch, action == 'restore');
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'edit', child: Text('Edit batch')),
                              if (batch.isActive)
                                const PopupMenuItem(value: 'archive', child: Text('Archive batch'))
                              else
                                const PopupMenuItem(value: 'restore', child: Text('Restore batch')),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
