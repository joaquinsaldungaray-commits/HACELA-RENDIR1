import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/performance/domain/drawdown_episode.dart';
import 'package:hacela_rendir/features/performance/domain/drawdown_summary.dart';
import 'package:hacela_rendir/features/performance/presentation/widgets/performance_metric_card.dart';

class DrawdownSection extends StatelessWidget {
  const DrawdownSection({
    required this.summary,
    super.key,
  });

  final DrawdownSummary summary;

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'Sin dato';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final maximumDrawdown =
        summary.maximumDrawdown;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Análisis de drawdown',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Caídas desde máximos históricos y tiempo de recuperación.',
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
              label: 'Drawdown actual',
              value:
                  '${summary.currentDrawdownPercent.toStringAsFixed(2)}%',
              subtitle: summary.isInDrawdown
                  ? '${summary.currentDrawdownDurationDays} días'
                  : 'Sin drawdown activo',
              icon: Icons.south_east_rounded,
              valueColor: summary.isInDrawdown
                  ? AppColors.danger
                  : AppColors.primary,
            ),
            PerformanceMetricCard(
              label: 'Máximo drawdown',
              value:
                  '${summary.maximumDrawdownPercent.toStringAsFixed(2)}%',
              subtitle: maximumDrawdown == null
                  ? 'Sin episodios'
                  : '${maximumDrawdown.durationDays} días',
              icon: Icons.trending_down_rounded,
              valueColor: maximumDrawdown == null
                  ? AppColors.primary
                  : AppColors.danger,
            ),
            PerformanceMetricCard(
              label: 'Pico actual',
              value:
                  'USD ${summary.currentPeakEquity.toStringAsFixed(2)}',
              subtitle: formatDate(
                summary.currentPeakDate,
              ),
              icon: Icons.landscape_outlined,
            ),
            PerformanceMetricCard(
              label: 'Episodios',
              value: '${summary.episodesCount}',
              subtitle:
                  '${summary.recoveredEpisodesCount} recuperados',
              icon: Icons.history_rounded,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (maximumDrawdown != null)
          _MaximumDrawdownCard(
            episode: maximumDrawdown,
          )
        else
          const _NoDrawdownCard(),
      ],
    );
  }
}

class _MaximumDrawdownCard extends StatelessWidget {
  const _MaximumDrawdownCard({
    required this.episode,
  });

  final DrawdownEpisode episode;

  String formatDate(DateTime? date) {
    if (date == null) {
      return 'No recuperado';
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.danger.withValues(
            alpha: 0.35,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peor episodio histórico',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DrawdownDetailRow(
            label: 'Pico',
            value:
                '${formatDate(episode.peakDate)} · '
                'USD ${episode.peakEquity.toStringAsFixed(2)}',
          ),
          const Divider(color: AppColors.border),
          _DrawdownDetailRow(
            label: 'Fondo',
            value:
                '${formatDate(episode.troughDate)} · '
                'USD ${episode.troughEquity.toStringAsFixed(2)}',
          ),
          const Divider(color: AppColors.border),
          _DrawdownDetailRow(
            label: 'Caída',
            value:
                '${episode.drawdownPercent.toStringAsFixed(2)}%',
            valueColor: AppColors.danger,
          ),
          const Divider(color: AppColors.border),
          _DrawdownDetailRow(
            label: 'Tiempo hasta el fondo',
            value: '${episode.daysToTrough} días',
          ),
          const Divider(color: AppColors.border),
          _DrawdownDetailRow(
            label: 'Duración total',
            value: '${episode.durationDays} días',
          ),
          const Divider(color: AppColors.border),
          _DrawdownDetailRow(
            label: 'Recuperación',
            value: formatDate(
              episode.recoveryDate,
            ),
            valueColor: episode.isRecovered
                ? AppColors.primary
                : AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _DrawdownDetailRow extends StatelessWidget {
  const _DrawdownDetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: AppTypography.bodyMedium.copyWith(
                color:
                    valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoDrawdownCard extends StatelessWidget {
  const _NoDrawdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.primary,
            size: 34,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Todavía no existen episodios de drawdown '
              'en el historial seleccionado.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}