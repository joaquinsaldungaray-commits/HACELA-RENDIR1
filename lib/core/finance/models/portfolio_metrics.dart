class PortfolioMetrics {
  const PortfolioMetrics({
    required this.investedValue,
    required this.marketValue,
    required this.profitLoss,
    required this.returnPercent,
    required this.positionsCount,
    required this.largestPositionWeight,
  });

  final double investedValue;
  final double marketValue;
  final double profitLoss;
  final double returnPercent;
  final int positionsCount;
  final double largestPositionWeight;

  bool get isPositive => profitLoss >= 0;
}