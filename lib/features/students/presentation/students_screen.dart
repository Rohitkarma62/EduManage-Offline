import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/student_providers.dart';

class StudentsScreen extends ConsumerStatefulWidget {
  const StudentsScreen({super.key});

  @override
  ConsumerState<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends ConsumerState<StudentsScreen> {
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
          .read(studentRepositoryProvider)
          .setStudentActive(id, isActive: isActive);
      ref.invalidate(studentsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(isActive ? 'Student reactivated' : 'Student deactivated'),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not update student status: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider(_query));
    return Scaffold(
      appBar: AppBar(title: const Text('Students')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/students/new'),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _search,
              onChanged: (v) => setState(() => _query = v.trim()),
              decoration: InputDecoration(
                labelText: 'Search students',
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
              title: const Text('Show inactive students'),
              value: _showInactive,
              onChanged: (value) => setState(() => _showInactive = value),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: students.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) =>
                    Center(child: Text('Could not load students: $e')),
                data: (records) {
                  final visible = records
                      .where((student) =>
                          _showInactive ? !student.isActive : student.isActive)
                      .toList();
                  if (visible.isEmpty) {
                    return Center(
                      child: Text(
                        _showInactive
                            ? 'No inactive students.'
                            : _query.isEmpty
                                ? 'No students yet. Add the first student.'
                                : 'No students match “$_query”.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: visible.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final student = visible[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            student.fullName.substring(0, 1).toUpperCase(),
                          ),
                        ),
                        title: Text(student.fullName),
                        subtitle: Text(
                          '${student.admissionNumber}${student.phone == null ? '' : ' • ${student.phone}'}',
                        ),
                        onTap: () =>
                            context.push('/students/${student.id}/edit'),
                        trailing: PopupMenuButton<String>(
                          tooltip: 'Student actions',
                          onSelected: (action) {
                            if (action == 'edit') {
                              context.push('/students/${student.id}/edit');
                            } else if (action == 'certificates') {
                              context.push('/students/${student.id}/certificates');
                            } else if (action == 'history') {
                              context
                                  .push('/students/${student.id}/assignments');
                            } else {
                              _setActive(student.id, action == 'activate');
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: ListTile(
                                leading: Icon(Icons.edit_outlined),
                                title: Text('Edit student'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'certificates',
                              child: ListTile(
                                leading: Icon(Icons.workspace_premium_outlined),
                                title: Text('Certificates'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'history',
                              child: ListTile(
                                leading: Icon(Icons.history),
                                title: Text('Assignment history'),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            PopupMenuItem(
                              value:
                                  student.isActive ? 'deactivate' : 'activate',
                              child: ListTile(
                                leading: Icon(student.isActive
                                    ? Icons.person_off_outlined
                                    : Icons.person_add_alt_1),
                                title: Text(student.isActive
                                    ? 'Deactivate'
                                    : 'Reactivate'),
                                contentPadding: EdgeInsets.zero,
                              ),
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
