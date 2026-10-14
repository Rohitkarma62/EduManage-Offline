import 'package:go_router/go_router.dart';

import '../../features/classes/presentation/class_form_screen.dart';
import '../../features/classes/presentation/classes_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/institute/presentation/institute_setup_screen.dart';
import '../../features/students/presentation/student_form_screen.dart';
import '../../features/students/presentation/students_screen.dart';

final GoRouter appRouter = GoRouter(routes: <RouteBase>[
  GoRoute(
    path: '/',
    name: 'dashboard',
    builder: (context, state) => const DashboardScreen(),
  ),
  GoRoute(
    path: '/institute-setup',
    name: 'institute-setup',
    builder: (context, state) => const InstituteSetupScreen(),
  ),
  GoRoute(
    path: '/classes',
    name: 'classes',
    builder: (context, state) => const ClassesScreen(),
  ),
  GoRoute(
    path: '/classes/new',
    name: 'class-new',
    builder: (context, state) => const ClassFormScreen(),
  ),
  GoRoute(
    path: '/classes/:id/edit',
    name: 'class-edit',
    builder: (context, state) => ClassFormScreen(
      classId: int.parse(state.pathParameters['id']!),
    ),
  ),
  GoRoute(
    path: '/students',
    name: 'students',
    builder: (context, state) => const StudentsScreen(),
  ),
  GoRoute(
    path: '/students/new',
    name: 'student-new',
    builder: (context, state) => const StudentFormScreen(),
  ),
  GoRoute(
    path: '/students/:id/edit',
    name: 'student-edit',
    builder: (context, state) => StudentFormScreen(
      studentId: int.parse(state.pathParameters['id']!),
    ),
  ),
]);
