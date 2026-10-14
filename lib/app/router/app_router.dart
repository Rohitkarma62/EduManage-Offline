import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/institute/presentation/institute_setup_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
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
  ],
);
