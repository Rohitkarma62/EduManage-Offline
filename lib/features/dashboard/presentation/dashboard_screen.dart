import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../institute/providers/institute_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final institute = ref.watch(instituteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('EduManage Offline')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Institute dashboard', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          institute.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const Text(
              'Institute details could not be loaded. Open setup to retry.',
            ),
            data: (value) => Text(
              value == null
                  ? 'Set up your institute to begin. Details stay on this device.'
                  : '${value.name} • Academic year ${value.academicYear}',
              style: textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Institute setup', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Save or update institute details in the local database.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/institute-setup'),
                      icon: const Icon(Icons.business_outlined),
                      label: Text(
                        institute.valueOrNull == null
                            ? 'Set up institute'
                            : 'Edit institute details',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Student management', style: textTheme.titleMedium),
                  const SizedBox(height: 6),
                  const Text(
                    'Add student records and search by name or admission '
                    'number. Records stay on this device.',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => context.push('/students'),
                      icon: const Icon(Icons.people_outline),
                      label: const Text('Open students'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Local database'),
                  SizedBox(height: 6),
                  Text(
                    'Institute and student details use Drift and SQLite. '
                    'Other management modules will be added in later '
                    'implementation steps.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
