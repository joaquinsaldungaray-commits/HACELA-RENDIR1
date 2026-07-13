class InvestmentResultSummary {
  const InvestmentResultSummary({
    required this.realizedProfit,
    required this.unrealizedProfit,
    required this.dividends,
    required this.fees,
    required this.totalResult,
  });

  final double realizedProfit;
  final double unrealizedProfit;
  final double dividends;
  final double fees;
  final double totalResult;
}