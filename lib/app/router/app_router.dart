import 'package:go_router/go_router.dart';

import 'package:hacela_rendir/features/onboarding/welcome_screen.dart';
import 'package:hacela_rendir/features/auth/login/login_screen.dart';
import 'package:hacela_rendir/features/auth/register/register_screen.dart';
import 'package:hacela_rendir/features/dashboard/dashboard_screen.dart';
import 'package:hacela_rendir/features/portfolio/presentation/portfolio_screen.dart';

import 'app_routes.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  routes: [
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.portfolio,
      builder: (context, state) => const PortfolioScreen(),
    ),
  ],
);