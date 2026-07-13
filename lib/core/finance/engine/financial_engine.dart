import 'package:hacela_rendir/core/finance/calculators/cash_calculator.dart';
import 'package:hacela_rendir/core/finance/calculators/portfolio_distribution_calculator.dart';
import 'package:hacela_rendir/core/finance/models/financial_snapshot.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/portfolio/services/position_builder.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';
import 'package:hacela_rendir/features/transactions/services/investment_result_calculator.dart';

abstract final class FinancialEngine {
  static FinancialSnapshot calculate({
    required List<PortfolioTransaction> transactions,
  }) {
    final positions = PositionBuilder.buildFromTransactions(
      transactions,
    );

    return calculateFromData(
      transactions: transactions,
      positions: positions,
    );
  }

  static FinancialSnapshot calculateFromData({
    required List<PortfolioTransaction> transactions,
    required List<PortfolioPosition> positions,
  }) {
    final cashBalance = CashCalculator.calculate(
      transactions,
    );

    final result = InvestmentResultCalculator.calculate(
      transactions: transactions,
      openPositions: positions,
    );

    final investedCapital = positions.fold<double>(
      0,
      (total, position) => total + position.invested,
    );

    final marketValue = positions.fold<double>(
      0,
      (total, position) => total + position.currentValue,
    );

    final absoluteReturn = result.totalResult;

    final returnPercent = investedCapital == 0
        ? 0.0
        : absoluteReturn / investedCapital * 100;

    final distribution =
        PortfolioDistributionCalculator.calculate(
      positions,
    );

    return FinancialSnapshot(
      cashBalance: cashBalance,
      investedCapital: investedCapital,
      marketValue: marketValue,
      realizedProfit: result.realizedProfit,
      unrealizedProfit: result.unrealizedProfit,
      dividends: result.dividends,
      fees: result.fees,
      totalResult: result.totalResult,
      absoluteReturn: absoluteReturn,
      returnPercent: returnPercent,
      positionsCount: positions.length,
      distribution: distribution,
    );
  }
}