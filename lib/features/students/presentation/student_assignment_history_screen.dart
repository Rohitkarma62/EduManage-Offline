import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../classes/providers/class_providers.dart';
import '../providers/student_providers.dart';

class StudentAssignmentHistoryScreen extends ConsumerWidget {
  const StudentAssignmentHistoryScreen({super.key, required this.studentId});

  final int studentId;

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(studentAssignmentHistoryProvider(studentId));
    final classes = ref.watch(allClassesProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assignment history'),
        actions: [
          IconButton(
            tooltip: 'Transfer student',
            onPressed: () async {
              final changed =
                  await context.push<bool>('/students/$studentId/transfer');
              if (changed == true) {
                ref.invalidate(studentAssignmentHistoryProvider(studentId));
                ref.invalidate(allClassesProvider);
              }
            },
            icon: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Could not load assignment history: $error'),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const Center(
              child: Text('No class assignment history recorded yet.'),
            );
          }
          return classes.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Could not load class names: $error')),
            data: (classRecords) {
              final names = {
                for (final record in classRecords) record.id: record.name
              };
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: records.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final assignment = records[index];
                  final isCurrent = assignment.effectiveTo == null;
                  final className =
                      names[assignment.classId] ?? 'Class #${assignment.classId}';
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(isCurrent ? Icons.school : Icons.history),
                      ),
                      title: Text(className),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('From: ${_date(assignment.effectiveFrom)}'),
                            Text(
                              'To: ${isCurrent ? 'Current assignment' : _date(assignment.effectiveTo!)}',
                            ),
                            if (assignment.batchId != null)
                              Text('Batch ID: ${assignment.batchId}'),
                            if (assignment.transferReason?.isNotEmpty == true)
                              Text('Reason: ${assignment.transferReason}'),
                            if (assignment.endReason?.isNotEmpty == true)
                              Text('End reason: ${assignment.endReason}'),
                          ],
                        ),
                      ),
                      trailing:
                          isCurrent ? const Chip(label: Text('Current')) : null,
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
