import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

enum AppButtonVariant {
  primary,
  secondary,
  danger,
  ghost,
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: 54,
      child: switch (variant) {
        AppButtonVariant.primary => FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              disabledBackgroundColor:
                  AppColors.primary.withValues(alpha: 0.35),
              disabledForegroundColor:
                  Colors.black.withValues(alpha: 0.45),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              foregroundColor: Colors.black,
            ),
          ),
        AppButtonVariant.secondary => OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              side: const BorderSide(
                color: AppColors.border,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
        AppButtonVariant.danger => FilledButton(
            onPressed: isLoading ? null : onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              foregroundColor: Colors.white,
            ),
          ),
        AppButtonVariant.ghost => TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _ButtonContent(
              label: label,
              icon: icon,
              isLoading: isLoading,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
      },
    );

    if (isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.isLoading,
    required this.foregroundColor,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool isLoading;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: foregroundColor,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(
            icon,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          style: AppTypography.labelLarge,
        ),
      ],
    );
  }
}