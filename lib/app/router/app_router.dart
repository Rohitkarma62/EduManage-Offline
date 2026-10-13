import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
  ],
);
