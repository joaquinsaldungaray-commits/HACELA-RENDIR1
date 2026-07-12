import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hacela_rendir/app/router/app_routes.dart';
import 'package:hacela_rendir/core/design_system/app_button.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hacela Rendir'),
        actions: [
          IconButton(
            onPressed: () {
              context.go(AppRoutes.welcome);
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTypography.displayMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tu cartera aparecerá acá cuando conectemos el backend.',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            AppButton(
              label: 'Volver al inicio',
              variant: AppButtonVariant.secondary,
              onPressed: () {
                context.go(AppRoutes.welcome);
              },
            ),
          ],
        ),
      ),
    );
  }
}