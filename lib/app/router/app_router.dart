import 'package:go_router/go_router.dart';

import '../../features/classes/presentation/batches_screen.dart';
import '../../features/classes/presentation/class_form_screen.dart';
import '../../features/classes/presentation/classes_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/attendance/presentation/attendance_screen.dart';
import '../../features/attendance/presentation/attendance_reports_screen.dart';
import '../../features/fees/presentation/fee_payments_screen.dart';
import '../../features/institute/presentation/institute_setup_screen.dart';
import '../../features/students/presentation/student_assignment_history_screen.dart';
import '../../features/students/presentation/student_form_screen.dart';
import '../../features/students/presentation/student_transfer_screen.dart';
import '../../features/students/presentation/students_screen.dart';
import '../../features/staff/presentation/staff_screen.dart';
import '../../features/staff/presentation/staff_salary_payments_screen.dart';

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
    path: '/classes/:id/batches',
    name: 'class-batches',
    builder: (context, state) => BatchesScreen(
      classId: int.parse(state.pathParameters['id']!),
    ),
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
  GoRoute(
    path: '/students/:id/assignments',
    name: 'student-assignment-history',
    builder: (context, state) => StudentAssignmentHistoryScreen(
      studentId: int.parse(state.pathParameters['id']!),
    ),
  ),
  GoRoute(
    path: '/students/:id/transfer',
    name: 'student-transfer',
    builder: (context, state) => StudentTransferScreen(
      studentId: int.parse(state.pathParameters['id']!),
    ),
  ),
  GoRoute(
    path: '/staff',
    name: 'staff',
    builder: (context, state) => const StaffScreen(),
  ),
  GoRoute(
    path: '/staff/salary-payments',
    name: 'staff-salary-payments',
    builder: (context, state) => const StaffSalaryPaymentsScreen(),
  ),
  GoRoute(
    path: '/attendance',
    name: 'attendance',
    builder: (context, state) => const AttendanceScreen(),
  ),
  GoRoute(
    path: '/attendance/reports',
    name: 'attendance-reports',
    builder: (context, state) => const AttendanceReportsScreen(),
  ),
  GoRoute(
    path: '/fees',
    name: 'fee-payments',
    builder: (context, state) => const FeePaymentsScreen(),
  ),
  GoRoute(
    path: '/fees/:id',
    name: 'student-fees',
    builder: (context, state) => StudentFeesScreen(
      studentId: int.parse(state.pathParameters['id']!),
    ),
  ),
]);
