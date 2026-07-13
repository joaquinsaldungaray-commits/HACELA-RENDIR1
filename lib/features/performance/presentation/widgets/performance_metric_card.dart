import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';

class PerformanceMetricCard extends StatelessWidget {
  const PerformanceMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    this.subtitle,
    this.valueColor,
    super.key,
  });

  final String label;
  final String value;
  final IconData icon;
  final String? subtitle;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final resolvedValueColor =
        valueColor ?? AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: valueColor ?? AppColors.primary,
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xxs,
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.titleLarge.copyWith(
              color: resolvedValueColor,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(
              height: AppSpacing.xxs,
            ),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}