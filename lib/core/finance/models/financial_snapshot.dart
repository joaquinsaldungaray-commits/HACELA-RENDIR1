import 'package:hacela_rendir/core/finance/models/portfolio_distribution.dart';

class FinancialSnapshot {
  const FinancialSnapshot({
    required this.cashBalance,
    required this.investedCapital,
    required this.marketValue,
    required this.realizedProfit,
    required this.unrealizedProfit,
    required this.dividends,
    required this.fees,
    required this.totalResult,
    required this.absoluteReturn,
    required this.returnPercent,
    required this.positionsCount,
    required this.distribution,
  });

  final double cashBalance;
  final double investedCapital;
  final double marketValue;

  final double realizedProfit;
  final double unrealizedProfit;
  final double dividends;
  final double fees;
  final double totalResult;

  final double absoluteReturn;
  final double returnPercent;

  final int positionsCount;

  final PortfolioDistribution distribution;

  double get totalEquity => cashBalance + marketValue;

  bool get isPositive => totalResult >= 0;
}