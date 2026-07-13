class PerformanceSummary {
  const PerformanceSummary({
    required this.startEquity,
    required this.endEquity,
    required this.netContributions,
    required this.absolutePerformance,
    required this.returnPercent,
    required this.currentDrawdownPercent,
    required this.maxDrawdownPercent,
    required this.peakEquity,
    required this.lowestEquity,
    required this.bestPeriodReturnPercent,
    required this.worstPeriodReturnPercent,
    required this.observationsCount,
  });

  final double startEquity;
  final double endEquity;
  final double netContributions;

  final double absolutePerformance;
  final double returnPercent;

  final double currentDrawdownPercent;
  final double maxDrawdownPercent;

  final double peakEquity;
  final double lowestEquity;

  final double bestPeriodReturnPercent;
  final double worstPeriodReturnPercent;

  final int observationsCount;

  bool get isPositive => absolutePerformance >= 0;

  factory PerformanceSummary.empty() {
    return const PerformanceSummary(
      startEquity: 0,
      endEquity: 0,
      netContributions: 0,
      absolutePerformance: 0,
      returnPercent: 0,
      currentDrawdownPercent: 0,
      maxDrawdownPercent: 0,
      peakEquity: 0,
      lowestEquity: 0,
      bestPeriodReturnPercent: 0,
      worstPeriodReturnPercent: 0,
      observationsCount: 0,
    );
  }
}