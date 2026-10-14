import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/class_repository.dart';

final classRepositoryProvider = Provider<ClassRepository>(
  (ref) => ClassRepository(ref.watch(appDatabaseProvider)),
);

final classesProvider = FutureProvider.family(
  (ref, String query) =>
      ref.watch(classRepositoryProvider).getClasses(query: query),
);

final activeClassesProvider = FutureProvider(
  (ref) => ref.watch(classRepositoryProvider).getClasses().then(
        (records) => records.where((record) => record.isActive).toList(),
      ),
);

final allClassesProvider = FutureProvider(
  (ref) => ref.watch(classRepositoryProvider).getClasses(),
);
