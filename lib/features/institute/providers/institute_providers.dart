import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../data/institute_repository.dart';

final instituteRepositoryProvider = Provider<InstituteRepository>((ref) {
  return InstituteRepository(ref.watch(appDatabaseProvider));
});

final instituteProvider = FutureProvider((ref) {
  return ref.watch(instituteRepositoryProvider).getInstitute();
});
