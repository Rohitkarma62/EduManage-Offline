import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';
import '../data/student_repository.dart';

final studentRepositoryProvider = Provider<StudentRepository>(
    (ref) => StudentRepository(ref.watch(appDatabaseProvider)));
final studentsProvider = FutureProvider.family((ref, String query) =>
    ref.watch(studentRepositoryProvider).getStudents(query: query));
final studentAssignmentHistoryProvider = FutureProvider.family(
    (ref, int studentId) =>
        ref.watch(studentRepositoryProvider).getAssignmentHistory(studentId));
