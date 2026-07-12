import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/design_system/widgets/app_logo.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppLogo(),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTypography.displayMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}