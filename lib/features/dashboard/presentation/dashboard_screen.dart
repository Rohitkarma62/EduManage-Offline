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
          _DashboardCard(
            title: 'Institute setup',
            description:
                'Save or update institute details in the local database.',
            buttonLabel: institute.valueOrNull == null
                ? 'Set up institute'
                : 'Edit institute details',
            icon: Icons.business_outlined,
            onPressed: () => context.push('/institute-setup'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Student management',
            description:
                'Add student records and search by name or admission number. Records stay on this device.',
            buttonLabel: 'Open students',
            icon: Icons.people_outline,
            onPressed: () => context.push('/students'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Staff management',
            description:
                'Maintain staff profiles, roles, contact details, and monthly salary amounts offline.',
            buttonLabel: 'Open staff',
            icon: Icons.badge_outlined,
            onPressed: () => context.push('/staff'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Salary payment history',
            description:
                'Record staff salary payments and review payment history and monthly totals offline.',
            buttonLabel: 'Open salary payments',
            icon: Icons.payments_outlined,
            onPressed: () => context.push('/staff/salary-payments'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Class & batch management',
            description:
                'Create classes or coaching batches by academic year, then assign students to them.',
            buttonLabel: 'Open classes & batches',
            icon: Icons.groups_outlined,
            onPressed: () => context.push('/classes'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Attendance',
            description:
                'Mark daily student attendance and review present, absent, and leave counts.',
            buttonLabel: 'Open attendance',
            icon: Icons.fact_check_outlined,
            onPressed: () => context.push('/attendance'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Attendance reports',
            description:
                'Review student-wise attendance percentages with class, batch, and date filters.',
            buttonLabel: 'Open attendance reports',
            icon: Icons.analytics_outlined,
            onPressed: () => context.push('/attendance/reports'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Expense tracking',
            description:
                'Record institute expenses, review payment methods, and track monthly spending offline.',
            buttonLabel: 'Open expenses',
            icon: Icons.receipt_long_outlined,
            onPressed: () => context.push('/expenses'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Exams & results',
            description:
                'Create class exams, enter student marks, and review result summaries offline.',
            buttonLabel: 'Open exams & results',
            icon: Icons.school_outlined,
            onPressed: () => context.push('/exams'),
          ),
          const SizedBox(height: 12),
          _DashboardCard(
            title: 'Fee payments',
            description:
                'Create fee charges, record partial payments, and review paid amounts and outstanding balances.',
            buttonLabel: 'Open fee payments',
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () => context.push('/fees'),
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
                    'Institute, student, class, batch, fee charge and payment data use the local Drift/SQLite database. Core workflows are designed to work offline.',
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

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.icon,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(description),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onPressed,
                  icon: Icon(icon),
                  label: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ),
      );
}
