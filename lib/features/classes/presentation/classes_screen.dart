import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/class_providers.dart';

class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool _showInactive = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _setActive(int id, bool isActive) async {
    try {
      await ref
          .read(classRepositoryProvider)
          .setClassActive(id, isActive: isActive);
      ref.invalidate(classesProvider);
      ref.invalidate(activeClassesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(isActive ? 'Class reactivated' : 'Class deactivated')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update class status: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final records = ref.watch(classesProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Classes & batches')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/classes/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add class'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _search,
              onChanged: (value) => setState(() => _query = value.trim()),
              decoration: InputDecoration(
                labelText: 'Search classes or academic year',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _search.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear),
                      ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Show inactive classes'),
              value: _showInactive,
              onChanged: (value) => setState(() => _showInactive = value),
            ),
            Expanded(
              child: records.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Center(child: Text('Could not load classes: $error')),
                data: (classes) {
                  final visible = classes
                      .where((record) =>
                          _showInactive ? !record.isActive : record.isActive)
                      .toList();
                  if (visible.isEmpty) {
                    return Center(
                      child: Text(
                        _showInactive
                            ? 'No inactive classes.'
                            : _query.isEmpty
                                ? 'No classes yet. Add the first class or batch.'
                                : 'No classes match “$_query”.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final record = visible[index];
                      void edit() => context.push('/classes/${record.id}/edit');
                      void openBatches() =>
                          context.push('/classes/${record.id}/batches');
                      return ListTile(
                        leading: CircleAvatar(
                          child: Icon(record.isActive
                              ? Icons.groups_outlined
                              : Icons.groups_2_outlined),
                        ),
                        title: Text(record.name),
                        subtitle: Text(
                          record.description == null ||
                                  record.description!.isEmpty
                              ? 'Academic year ${record.academicYear}'
                              : 'Academic year ${record.academicYear}\n${record.description}',
                        ),
                        isThreeLine: record.description != null &&
                            record.description!.isNotEmpty,
                        onTap: openBatches,
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'edit') {
                              edit();
                            } else if (action == 'batches') {
                              openBatches();
                            } else {
                              _setActive(record.id, action == 'activate');
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                                value: 'batches',
                                child: Text('Manage batches')),
                            const PopupMenuItem(
                                value: 'edit', child: Text('Edit')),
                            PopupMenuItem(
                              value:
                                  record.isActive ? 'deactivate' : 'activate',
                              child: Text(record.isActive
                                  ? 'Deactivate'
                                  : 'Reactivate'),
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
      ),
    );
  }
}
