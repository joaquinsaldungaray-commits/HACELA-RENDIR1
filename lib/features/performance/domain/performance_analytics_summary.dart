class PerformanceAnalyticsSummary {
  const PerformanceAnalyticsSummary({
    required this.twrPercent,
    required this.cagrPercent,
    required this.annualizedVolatilityPercent,
    required this.sharpeRatio,
    required this.sortinoRatio,
    required this.averagePeriodReturnPercent,
    required this.bestPeriodReturnPercent,
    required this.worstPeriodReturnPercent,
    required this.positivePeriods,
    required this.negativePeriods,
    required this.periodsCount,
    required this.observationsCount,
  });

  final double twrPercent;
  final double cagrPercent;
  final double annualizedVolatilityPercent;

  final double sharpeRatio;
  final double sortinoRatio;

  final double averagePeriodReturnPercent;
  final double bestPeriodReturnPercent;
  final double worstPeriodReturnPercent;

  final int positivePeriods;
  final int negativePeriods;
  final int periodsCount;
  final int observationsCount;

  bool get hasEnoughData => periodsCount > 0;

  bool get isPositive => twrPercent >= 0;

  factory PerformanceAnalyticsSummary.empty({
    int observationsCount = 0,
  }) {
    return PerformanceAnalyticsSummary(
      twrPercent: 0,
      cagrPercent: 0,
      annualizedVolatilityPercent: 0,
      sharpeRatio: 0,
      sortinoRatio: 0,
      averagePeriodReturnPercent: 0,
      bestPeriodReturnPercent: 0,
      worstPeriodReturnPercent: 0,
      positivePeriods: 0,
      negativePeriods: 0,
      periodsCount: 0,
      observationsCount: observationsCount,
    );
  }
}