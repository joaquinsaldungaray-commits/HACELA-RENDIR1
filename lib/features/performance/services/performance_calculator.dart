import 'dart:math' as math;

import 'package:hacela_rendir/features/performance/domain/performance_period.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/performance/domain/performance_summary.dart';

abstract final class PerformanceCalculator {
  static List<PerformanceSnapshot> filterByPeriod({
    required List<PerformanceSnapshot> snapshots,
    required PerformancePeriod period,
    DateTime? now,
  }) {
    if (snapshots.isEmpty) {
      return [];
    }

    final ordered = List<PerformanceSnapshot>.from(
      snapshots,
    )..sort(
        (first, second) => first.recordedAt.compareTo(
          second.recordedAt,
        ),
      );

    final startDate = period.startDate(
      now: now ?? DateTime.now(),
    );

    if (startDate == null) {
      return ordered;
    }

    return ordered
        .where(
          (snapshot) =>
              !snapshot.recordedAt.isBefore(startDate),
        )
        .toList();
  }

  static PerformanceSummary calculate(
    List<PerformanceSnapshot> snapshots,
  ) {
    if (snapshots.isEmpty) {
      return PerformanceSummary.empty();
    }

    final ordered = List<PerformanceSnapshot>.from(
      snapshots,
    )..sort(
        (first, second) => first.recordedAt.compareTo(
          second.recordedAt,
        ),
      );

    final first = ordered.first;
    final last = ordered.last;

    var peakEquity = first.totalEquity;
    var lowestEquity = first.totalEquity;

    var maxDrawdownPercent = 0.0;
    var bestPeriodReturnPercent = 0.0;
    var worstPeriodReturnPercent = 0.0;

    for (var index = 0; index < ordered.length; index++) {
      final current = ordered[index];

      peakEquity = math.max(
        peakEquity,
        current.totalEquity,
      );

      lowestEquity = math.min(
        lowestEquity,
        current.totalEquity,
      );

      if (peakEquity > 0) {
        final drawdown =
            (current.totalEquity - peakEquity) /
                peakEquity *
                100;

        maxDrawdownPercent = math.min(
          maxDrawdownPercent,
          drawdown,
        );
      }

      if (index == 0) {
        continue;
      }

      final previous = ordered[index - 1];

      final contributionDifference =
          current.netContributions -
              previous.netContributions;

      final adjustedStartEquity =
          previous.totalEquity +
              contributionDifference;

      final periodReturnPercent =
          adjustedStartEquity == 0
              ? 0.0
              : (current.totalEquity -
                          adjustedStartEquity) /
                      adjustedStartEquity *
                  100;

      bestPeriodReturnPercent = math.max(
        bestPeriodReturnPercent,
        periodReturnPercent,
      );

      worstPeriodReturnPercent = math.min(
        worstPeriodReturnPercent,
        periodReturnPercent,
      );
    }

    final contributionChange =
        last.netContributions -
            first.netContributions;

    final adjustedInitialEquity =
        first.totalEquity + contributionChange;

    final absolutePerformance =
        last.totalEquity -
            first.totalEquity -
            contributionChange;

    final returnPercent = adjustedInitialEquity == 0
        ? 0.0
        : absolutePerformance /
            adjustedInitialEquity *
            100;

    final currentDrawdownPercent = peakEquity == 0
        ? 0.0
        : (last.totalEquity - peakEquity) /
            peakEquity *
            100;

    return PerformanceSummary(
      startEquity: first.totalEquity,
      endEquity: last.totalEquity,
      netContributions: contributionChange,
      absolutePerformance: absolutePerformance,
      returnPercent: returnPercent,
      currentDrawdownPercent:
          currentDrawdownPercent,
      maxDrawdownPercent:
          maxDrawdownPercent,
      peakEquity: peakEquity,
      lowestEquity: lowestEquity,
      bestPeriodReturnPercent:
          bestPeriodReturnPercent,
      worstPeriodReturnPercent:
          worstPeriodReturnPercent,
      observationsCount: ordered.length,
    );
  }
}