import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/institute/presentation/institute_setup_screen.dart';
import '../../features/students/presentation/student_form_screen.dart';
import '../../features/students/presentation/students_screen.dart';

final GoRouter appRouter = GoRouter(routes: <RouteBase>[
  GoRoute(path: '/', name: 'dashboard', builder: (context, state) => const DashboardScreen()),
  GoRoute(path: '/institute-setup', name: 'institute-setup', builder: (context, state) => const InstituteSetupScreen()),
  GoRoute(path: '/students', name: 'students', builder: (context, state) => const StudentsScreen()),
  GoRoute(path: '/students/new', name: 'student-new', builder: (context, state) => const StudentFormScreen()),
]);
