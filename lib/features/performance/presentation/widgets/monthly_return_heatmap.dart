import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/performance/domain/monthly_return.dart';
import 'package:hacela_rendir/features/performance/domain/yearly_return.dart';

class MonthlyReturnHeatmap extends StatelessWidget {
  const MonthlyReturnHeatmap({
    required this.yearlyReturns,
    super.key,
  });

  final List<YearlyReturn> yearlyReturns;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calendario de rentabilidad',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Retornos mensuales y resultado acumulado de cada año.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(
            AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: yearlyReturns.isEmpty
              ? const _EmptyHeatmap()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HeatmapHeader(),
                      const SizedBox(height: AppSpacing.sm),
                      for (final yearlyReturn
                          in yearlyReturns.reversed) ...[
                        _HeatmapYearRow(
                          yearlyReturn: yearlyReturn,
                        ),
                        const SizedBox(
                          height: AppSpacing.sm,
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _HeatmapHeader extends StatelessWidget {
  const _HeatmapHeader();

  static const monthLabels = [
    'ENE',
    'FEB',
    'MAR',
    'ABR',
    'MAY',
    'JUN',
    'JUL',
    'AGO',
    'SEP',
    'OCT',
    'NOV',
    'DIC',
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _HeaderCell(
          label: 'AÑO',
          width: 66,
        ),
        for (final month in monthLabels)
          _HeaderCell(
            label: month,
            width: 72,
          ),
        const _HeaderCell(
          label: 'TOTAL',
          width: 84,
        ),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.width,
  });

  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _HeatmapYearRow extends StatelessWidget {
  const _HeatmapYearRow({
    required this.yearlyReturn,
  });

  final YearlyReturn yearlyReturn;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 66,
          child: Text(
            '${yearlyReturn.year}',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        for (var month = 1; month <= 12; month++)
          _MonthlyReturnCell(
            monthlyReturn:
                yearlyReturn.month(month),
          ),
        _YearlyReturnCell(
          value: yearlyReturn.returnPercent,
        ),
      ],
    );
  }
}

class _MonthlyReturnCell extends StatelessWidget {
  const _MonthlyReturnCell({
    required this.monthlyReturn,
  });

  final MonthlyReturn? monthlyReturn;

  @override
  Widget build(BuildContext context) {
    final value = monthlyReturn?.returnPercent;

    final backgroundColor =
        _backgroundColor(value);

    final foregroundColor =
        _foregroundColor(value);

    return Container(
      width: 64,
      height: 42,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Text(
        value == null
            ? '—'
            : '${value >= 0 ? '+' : ''}'
                '${value.toStringAsFixed(1)}%',
        style: AppTypography.labelSmall.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Color _backgroundColor(double? value) {
    if (value == null) {
      return AppColors.surfaceAlt;
    }

    final intensity =
        (value.abs() / 10).clamp(0.08, 0.55);

    if (value >= 0) {
      return AppColors.primary.withValues(
        alpha: intensity,
      );
    }

    return AppColors.danger.withValues(
      alpha: intensity,
    );
  }

  Color _foregroundColor(double? value) {
    if (value == null) {
      return AppColors.textSecondary;
    }

    return value >= 0
        ? AppColors.primary
        : AppColors.danger;
  }
}

class _YearlyReturnCell extends StatelessWidget {
  const _YearlyReturnCell({
    required this.value,
  });

  final double value;

  @override
  Widget build(BuildContext context) {
    final valueColor =
        value >= 0 ? AppColors.primary : AppColors.danger;

    return Container(
      width: 76,
      height: 42,
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: valueColor.withValues(
          alpha: 0.14,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: valueColor.withValues(
            alpha: 0.4,
          ),
        ),
      ),
      child: Text(
        '${value >= 0 ? '+' : ''}'
        '${value.toStringAsFixed(1)}%',
        style: AppTypography.labelSmall.copyWith(
          color: valueColor,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyHeatmap extends StatelessWidget {
  const _EmptyHeatmap();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
      ),
      child: Column(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 46,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Todavía no hay retornos mensuales',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Se necesitan registros históricos de distintos meses '
            'para construir el calendario.',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}