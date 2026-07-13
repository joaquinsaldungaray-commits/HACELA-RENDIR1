import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hacela_rendir/core/design_system/app_spacing.dart';
import 'package:hacela_rendir/core/design_system/app_typography.dart';
import 'package:hacela_rendir/core/theme/app_theme.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';

class EquityHistoryChart extends StatelessWidget {
  const EquityHistoryChart({
    required this.snapshots,
    super.key,
  });

  final List<PerformanceSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    if (snapshots.isEmpty) {
      return const _EmptyChart();
    }

    final orderedSnapshots =
        List<PerformanceSnapshot>.from(
      snapshots,
    )..sort(
        (first, second) =>
            first.recordedAt.compareTo(
          second.recordedAt,
        ),
      );

    final firstSnapshot = orderedSnapshots.first;
    final lastSnapshot = orderedSnapshots.last;

    final isPositive =
        lastSnapshot.totalEquity >=
            firstSnapshot.totalEquity;

    final chartColor = isPositive
        ? AppColors.primary
        : AppColors.danger;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Evolución del patrimonio',
                  style:
                      AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${orderedSnapshots.length} registros',
                style:
                    AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: AppSpacing.lg,
          ),
          SizedBox(
            width: double.infinity,
            height: 260,
            child: CustomPaint(
              painter: _EquityChartPainter(
                snapshots: orderedSnapshots,
                lineColor: chartColor,
                gridColor: AppColors.border,
                textColor: AppColors.textSecondary,
                surfaceColor: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Row(
            children: [
              Expanded(
                child: _ChartLegendValue(
                  label: 'Inicio',
                  value:
                      firstSnapshot.totalEquity,
                ),
              ),
              Expanded(
                child: _ChartLegendValue(
                  label: 'Actual',
                  value:
                      lastSnapshot.totalEquity,
                  alignment:
                      CrossAxisAlignment.end,
                  valueColor: chartColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChartLegendValue extends StatelessWidget {
  const _ChartLegendValue({
    required this.label,
    required this.value,
    this.alignment =
        CrossAxisAlignment.start,
    this.valueColor,
  });

  final String label;
  final double value;
  final CrossAxisAlignment alignment;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(
          height: AppSpacing.xxs,
        ),
        Text(
          'USD ${value.toStringAsFixed(2)}',
          style: AppTypography.titleMedium.copyWith(
            color:
                valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 260,
      padding: const EdgeInsets.all(
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.area_chart_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(
            height: AppSpacing.md,
          ),
          Text(
            'Todavía no hay historial',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(
            height: AppSpacing.xs,
          ),
          Text(
            'Los registros diarios de patrimonio aparecerán acá.',
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

class _EquityChartPainter extends CustomPainter {
  const _EquityChartPainter({
    required this.snapshots,
    required this.lineColor,
    required this.gridColor,
    required this.textColor,
    required this.surfaceColor,
  });

  final List<PerformanceSnapshot> snapshots;
  final Color lineColor;
  final Color gridColor;
  final Color textColor;
  final Color surfaceColor;

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    if (snapshots.isEmpty) {
      return;
    }

    const leftPadding = 58.0;
    const rightPadding = 12.0;
    const topPadding = 14.0;
    const bottomPadding = 28.0;

    final chartWidth = math.max(
      1.0,
      size.width -
          leftPadding -
          rightPadding,
    );

    final chartHeight = math.max(
      1.0,
      size.height -
          topPadding -
          bottomPadding,
    );

    final values = snapshots
        .map(
          (snapshot) =>
              snapshot.totalEquity,
        )
        .toList();

    var minimumValue =
        values.reduce(math.min);

    var maximumValue =
        values.reduce(math.max);

    if (maximumValue == minimumValue) {
      final margin = maximumValue == 0
          ? 1.0
          : maximumValue.abs() * 0.05;

      minimumValue -= margin;
      maximumValue += margin;
    }

    final valueRange =
        maximumValue - minimumValue;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    const horizontalLines = 4;

    for (var index = 0;
        index <= horizontalLines;
        index++) {
      final progress =
          index / horizontalLines;

      final y =
          topPadding +
              chartHeight * progress;

      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(
          leftPadding + chartWidth,
          y,
        ),
        gridPaint,
      );

      final labelValue =
          maximumValue -
              valueRange * progress;

      final textPainter = TextPainter(
        text: TextSpan(
          text: _formatCompactValue(
            labelValue,
          ),
          style: TextStyle(
            color: textColor,
            fontSize: 10,
          ),
        ),
        textDirection:
            TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          0,
          y -
              textPainter.height / 2,
        ),
      );
    }

    final points = <Offset>[];

    for (var index = 0;
        index < snapshots.length;
        index++) {
      final xProgress =
          snapshots.length == 1
              ? 0.5
              : index /
                  (snapshots.length - 1);

      final valueProgress =
          (snapshots[index].totalEquity -
                  minimumValue) /
              valueRange;

      final x =
          leftPadding +
              chartWidth * xProgress;

      final y =
          topPadding +
              chartHeight *
                  (1 - valueProgress);

      points.add(
        Offset(x, y),
      );
    }

    final areaPath = Path();

    areaPath.moveTo(
      points.first.dx,
      topPadding + chartHeight,
    );

    areaPath.lineTo(
      points.first.dx,
      points.first.dy,
    );

    for (final point in points.skip(1)) {
      areaPath.lineTo(
        point.dx,
        point.dy,
      );
    }

    areaPath.lineTo(
      points.last.dx,
      topPadding + chartHeight,
    );

    areaPath.close();

    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(
            alpha: 0.28,
          ),
          lineColor.withValues(
            alpha: 0.02,
          ),
        ],
      ).createShader(
        Rect.fromLTWH(
          leftPadding,
          topPadding,
          chartWidth,
          chartHeight,
        ),
      );

    canvas.drawPath(
      areaPath,
      areaPaint,
    );

    final linePath = Path()
      ..moveTo(
        points.first.dx,
        points.first.dy,
      );

    for (final point in points.skip(1)) {
      linePath.lineTo(
        point.dx,
        point.dy,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      linePath,
      linePaint,
    );

    final pointPaint = Paint()
      ..color = lineColor;

    for (final point in points) {
      canvas.drawCircle(
        point,
        3.5,
        pointPaint,
      );

      canvas.drawCircle(
        point,
        1.7,
        Paint()..color = surfaceColor,
      );
    }

    final firstDate =
        snapshots.first.recordedAt;

    final lastDate =
        snapshots.last.recordedAt;

    final firstDatePainter = TextPainter(
      text: TextSpan(
        text: _formatDate(firstDate),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    firstDatePainter.paint(
      canvas,
      Offset(
        leftPadding,
        size.height -
            firstDatePainter.height,
      ),
    );

    final lastDatePainter = TextPainter(
      text: TextSpan(
        text: _formatDate(lastDate),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    lastDatePainter.paint(
      canvas,
      Offset(
        size.width -
            rightPadding -
            lastDatePainter.width,
        size.height -
            lastDatePainter.height,
      ),
    );
  }

  static String _formatCompactValue(
    double value,
  ) {
    final absoluteValue = value.abs();

    if (absoluteValue >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    }

    if (absoluteValue >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toStringAsFixed(0);
  }

  static String _formatDate(
    DateTime date,
  ) {
    final day =
        date.day.toString().padLeft(2, '0');

    final month =
        date.month.toString().padLeft(2, '0');

    return '$day/$month';
  }

  @override
  bool shouldRepaint(
    covariant _EquityChartPainter oldDelegate,
  ) {
    return oldDelegate.snapshots != snapshots ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}