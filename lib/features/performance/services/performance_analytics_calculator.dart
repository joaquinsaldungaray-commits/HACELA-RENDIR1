import 'dart:math' as math;

import 'package:hacela_rendir/features/performance/domain/performance_analytics_summary.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';

abstract final class PerformanceAnalyticsCalculator {
  static PerformanceAnalyticsSummary calculate({
    required List<PerformanceSnapshot> snapshots,
    double annualRiskFreeRatePercent = 0,
    int periodsPerYear = 252,
  }) {
    if (snapshots.length < 2) {
      return PerformanceAnalyticsSummary.empty(
        observationsCount: snapshots.length,
      );
    }

    final orderedSnapshots =
        List<PerformanceSnapshot>.from(snapshots)
          ..sort(
            (first, second) =>
                first.recordedAt.compareTo(
              second.recordedAt,
            ),
          );

    final periodReturns = _calculatePeriodReturns(
      orderedSnapshots,
    );

    if (periodReturns.isEmpty) {
      return PerformanceAnalyticsSummary.empty(
        observationsCount: orderedSnapshots.length,
      );
    }

    final twr = _calculateTwr(
      periodReturns,
    );

    final cagr = _calculateAnnualizedReturn(
      totalReturn: twr,
      firstDate: orderedSnapshots.first.recordedAt,
      lastDate: orderedSnapshots.last.recordedAt,
    );

    final averagePeriodReturn =
        periodReturns.reduce(
              (first, second) => first + second,
            ) /
            periodReturns.length;

    final periodicVolatility = _sampleStandardDeviation(
      periodReturns,
    );

    final annualizedVolatility =
        periodicVolatility *
            math.sqrt(
              periodsPerYear,
            );

    final annualRiskFreeRate =
        annualRiskFreeRatePercent / 100;

    final sharpeRatio = annualizedVolatility == 0
        ? 0.0
        : (cagr - annualRiskFreeRate) /
            annualizedVolatility;

    final annualizedDownsideDeviation =
        _annualizedDownsideDeviation(
      returns: periodReturns,
      annualRiskFreeRate: annualRiskFreeRate,
      periodsPerYear: periodsPerYear,
    );

    final sortinoRatio =
        annualizedDownsideDeviation == 0
            ? 0.0
            : (cagr - annualRiskFreeRate) /
                annualizedDownsideDeviation;

    final positivePeriods = periodReturns
        .where(
          (periodReturn) => periodReturn > 0,
        )
        .length;

    final negativePeriods = periodReturns
        .where(
          (periodReturn) => periodReturn < 0,
        )
        .length;

    return PerformanceAnalyticsSummary(
      twrPercent: twr * 100,
      cagrPercent: cagr * 100,
      annualizedVolatilityPercent:
          annualizedVolatility * 100,
      sharpeRatio: sharpeRatio,
      sortinoRatio: sortinoRatio,
      averagePeriodReturnPercent:
          averagePeriodReturn * 100,
      bestPeriodReturnPercent:
          periodReturns.reduce(math.max) * 100,
      worstPeriodReturnPercent:
          periodReturns.reduce(math.min) * 100,
      positivePeriods: positivePeriods,
      negativePeriods: negativePeriods,
      periodsCount: periodReturns.length,
      observationsCount: orderedSnapshots.length,
    );
  }

  static List<double> _calculatePeriodReturns(
    List<PerformanceSnapshot> snapshots,
  ) {
    final returns = <double>[];

    for (var index = 1;
        index < snapshots.length;
        index++) {
      final previous = snapshots[index - 1];
      final current = snapshots[index];

      if (previous.totalEquity == 0) {
        continue;
      }

      final contributionChange =
          current.netContributions -
              previous.netContributions;

      final investmentResult =
          current.totalEquity -
              previous.totalEquity -
              contributionChange;

      final periodReturn =
          investmentResult /
              previous.totalEquity;

      if (periodReturn.isFinite) {
        returns.add(
          periodReturn,
        );
      }
    }

    return returns;
  }

  static double _calculateTwr(
    List<double> periodReturns,
  ) {
    var growthFactor = 1.0;

    for (final periodReturn in periodReturns) {
      growthFactor *= 1 + periodReturn;
    }

    return growthFactor - 1;
  }

  static double _calculateAnnualizedReturn({
    required double totalReturn,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final elapsedDays =
        lastDate.difference(firstDate).inDays;

    if (elapsedDays <= 0) {
      return 0;
    }

    final growthFactor = 1 + totalReturn;

    if (growthFactor <= 0) {
      return -1;
    }

    final elapsedYears =
        elapsedDays / 365.2425;

    if (elapsedYears <= 0) {
      return 0;
    }

    return math.pow(
          growthFactor,
          1 / elapsedYears,
        ).toDouble() -
        1;
  }

  static double _sampleStandardDeviation(
    List<double> values,
  ) {
    if (values.length < 2) {
      return 0;
    }

    final mean = values.reduce(
          (first, second) => first + second,
        ) /
        values.length;

    var squaredDifferences = 0.0;

    for (final value in values) {
      final difference = value - mean;

      squaredDifferences +=
          difference * difference;
    }

    final variance =
        squaredDifferences /
            (values.length - 1);

    return math.sqrt(
      variance,
    );
  }

  static double _annualizedDownsideDeviation({
    required List<double> returns,
    required double annualRiskFreeRate,
    required int periodsPerYear,
  }) {
    if (returns.isEmpty || periodsPerYear <= 0) {
      return 0;
    }

    final periodicTargetReturn =
        math.pow(
          1 + annualRiskFreeRate,
          1 / periodsPerYear,
        ).toDouble() -
        1;

    var squaredDownsideDifferences = 0.0;

    for (final periodReturn in returns) {
      final difference =
          periodReturn - periodicTargetReturn;

      final downsideDifference =
          math.min(
        0.0,
        difference,
      );

      squaredDownsideDifferences +=
          downsideDifference *
              downsideDifference;
    }

    final downsideVariance =
        squaredDownsideDifferences /
            returns.length;

    final periodicDownsideDeviation =
        math.sqrt(
      downsideVariance,
    );

    return periodicDownsideDeviation *
        math.sqrt(
          periodsPerYear,
        );
  }
}