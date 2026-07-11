import 'package:go_router/go_router.dart';

import '../../features/onboarding/welcome_screen.dart';
import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
  ],
);