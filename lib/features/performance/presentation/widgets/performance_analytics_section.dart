import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/performance/domain/performance_analytics_summary.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/performance_metric_card.dart';

class PerformanceAnalyticsSection extends StatelessWidget {
  const PerformanceAnalyticsSection({
    required this.analytics,
    super.key,
  });

  final PerformanceAnalyticsSummary analytics;

  String signedPercent(double value) {
    return '${value >= 0 ? '+' : ''}${value.toStringAsFixed(2)}%';
  }

  String ratio(double value) {
    if (!value.isFinite) {
      return 'N/D';
    }

    return value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final resultColor = analytics.twrPercent >= 0
        ? AppColors.primary
        : AppColors.danger;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Métricas avanzadas',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Rentabilidad, riesgo y consistencia histórica.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.55,
          children: [
            PerformanceMetricCard(
              label: 'TWR',
              value: signedPercent(
                analytics.twrPercent,
              ),
              subtitle: 'Retorno ponderado por tiempo',
              icon: Icons.timeline_rounded,
              valueColor: resultColor,
            ),
            PerformanceMetricCard(
              label: 'CAGR',
              value: signedPercent(
                analytics.cagrPercent,
              ),
              subtitle: 'Retorno anual compuesto',
              icon: Icons.auto_graph_rounded,
              valueColor: analytics.cagrPercent >= 0
                  ? AppColors.primary
                  : AppColors.danger,
            ),
            PerformanceMetricCard(
              label: 'Volatilidad anual',
              value:
                  '${analytics.annualizedVolatilityPercent.toStringAsFixed(2)}%',
              subtitle: 'Variación anualizada',
              icon: Icons.monitor_heart_outlined,
            ),
            PerformanceMetricCard(
              label: 'Sharpe Ratio',
              value: ratio(
                analytics.sharpeRatio,
              ),
              subtitle: 'Retorno por riesgo total',
              icon: Icons.balance_rounded,
              valueColor: analytics.sharpeRatio >= 0
                  ? AppColors.primary
                  : AppColors.danger,
            ),
            PerformanceMetricCard(
              label: 'Sortino Ratio',
              value: ratio(
                analytics.sortinoRatio,
              ),
              subtitle: 'Retorno por riesgo negativo',
              icon: Icons.south_east_rounded,
              valueColor: analytics.sortinoRatio >= 0
                  ? AppColors.primary
                  : AppColors.danger,
            ),
            PerformanceMetricCard(
              label: 'Retorno promedio',
              value: signedPercent(
                analytics.averagePeriodReturnPercent,
              ),
              subtitle: 'Promedio por observación',
              icon: Icons.functions_rounded,
              valueColor:
                  analytics.averagePeriodReturnPercent >= 0
                      ? AppColors.primary
                      : AppColors.danger,
            ),
            PerformanceMetricCard(
              label: 'Períodos positivos',
              value:
                  '${analytics.positivePeriods}',
              subtitle:
                  'De ${analytics.periodsCount} períodos',
              icon: Icons.arrow_upward_rounded,
              valueColor: AppColors.primary,
            ),
            PerformanceMetricCard(
              label: 'Períodos negativos',
              value:
                  '${analytics.negativePeriods}',
              subtitle:
                  'De ${analytics.periodsCount} períodos',
              icon: Icons.arrow_downward_rounded,
              valueColor: analytics.negativePeriods > 0
                  ? AppColors.danger
                  : AppColors.primary,
            ),
          ],
        ),
        if (analytics.observationsCount < 30) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(
              AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.border,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Estas métricas todavía tienen pocas observaciones. '
                    'CAGR, volatilidad, Sharpe y Sortino serán más '
                    'representativos cuando exista un historial más largo.',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}