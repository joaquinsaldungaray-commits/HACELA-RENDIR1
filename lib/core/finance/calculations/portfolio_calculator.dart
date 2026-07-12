import 'package:hacela_rendir/core/finance/models/portfolio_metrics.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

abstract final class PortfolioCalculator {
  static PortfolioMetrics calculate(
    List<PortfolioPosition> positions,
  ) {
    if (positions.isEmpty) {
      return const PortfolioMetrics(
        investedValue: 0,
        marketValue: 0,
        profitLoss: 0,
        returnPercent: 0,
        positionsCount: 0,
        largestPositionWeight: 0,
      );
    }

    final investedValue = positions.fold<double>(
      0,
      (total, position) => total + position.invested,
    );

    final marketValue = positions.fold<double>(
      0,
      (total, position) => total + position.currentValue,
    );

    final profitLoss = marketValue - investedValue;

    final returnPercent = investedValue == 0
        ? 0.0
        : profitLoss / investedValue * 100;

    var largestPositionValue = 0.0;

    for (final position in positions) {
      if (position.currentValue > largestPositionValue) {
        largestPositionValue = position.currentValue;
      }
    }

    final largestPositionWeight = marketValue == 0
        ? 0.0
        : largestPositionValue / marketValue * 100;

    return PortfolioMetrics(
      investedValue: investedValue,
      marketValue: marketValue,
      profitLoss: profitLoss,
      returnPercent: returnPercent,
      positionsCount: positions.length,
      largestPositionWeight: largestPositionWeight,
    );
  }
}