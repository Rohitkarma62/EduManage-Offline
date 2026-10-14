import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('EduManage Offline'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Institute dashboard',
            style: textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Application foundation is being set up. No institute data has '
            'been created or loaded yet.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          const _SetupNotice(
            title: 'Local database',
            detail: 'Drift schema and migrations are the next foundation task.',
          ),
          const SizedBox(height: 12),
          const _SetupNotice(
            title: 'Institute setup',
            detail:
                'Onboarding and institute settings are not implemented yet.',
          ),
        ],
      ),
    );
  }
}

class _SetupNotice extends StatelessWidget {
  const _SetupNotice({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(detail),
          ],
        ),
      ),
    );
  }
}
