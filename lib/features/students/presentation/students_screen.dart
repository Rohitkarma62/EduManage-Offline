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
  @override
  void dispose() { _search.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final students = ref.watch(studentsProvider(_query));
    return Scaffold(appBar: AppBar(title: const Text('Students')), floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/students/new'), icon: const Icon(Icons.person_add_alt_1), label: const Text('Add student')), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      TextField(controller: _search, onChanged: (v) => setState(() => _query = v.trim()), decoration: InputDecoration(labelText: 'Search students', prefixIcon: const Icon(Icons.search), suffixIcon: _query.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() => _query = ''); }, icon: const Icon(Icons.clear)), border: const OutlineInputBorder())),
      const SizedBox(height: 12),
      Expanded(child: students.when(loading: () => const Center(child: CircularProgressIndicator()), error: (e, s) => Center(child: Text('Could not load students: $e')), data: (records) {
        if (records.isEmpty) return Center(child: Text(_query.isEmpty ? 'No students yet. Add the first student.' : 'No students match “$_query”.', textAlign: TextAlign.center));
        return ListView.separated(itemCount: records.length, separatorBuilder: (_, __) => const Divider(height: 1), itemBuilder: (context, i) { final student = records[i]; return ListTile(leading: CircleAvatar(child: Text(student.fullName.substring(0, 1).toUpperCase())), title: Text(student.fullName), subtitle: Text('${student.admissionNumber}${student.phone == null ? '' : ' • ${student.phone}'}')); });
      })),
    ])));
  }
}
