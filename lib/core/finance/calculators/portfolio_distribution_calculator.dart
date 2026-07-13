import 'package:hacela_rendir/core/finance/models/portfolio_distribution.dart';
import 'package:hacela_rendir/features/assets/domain/asset_type.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

abstract final class PortfolioDistributionCalculator {
  static PortfolioDistribution calculate(
    List<PortfolioPosition> positions,
  ) {
    final totalMarketValue = positions.fold<double>(
      0,
      (total, position) => total + position.currentValue,
    );

    return PortfolioDistribution(
      bySector: _groupBy(
        positions: positions,
        totalMarketValue: totalMarketValue,
        labelSelector: (position) => position.sector,
      ),
      byCountry: _groupBy(
        positions: positions,
        totalMarketValue: totalMarketValue,
        labelSelector: (position) => position.country,
      ),
      byCurrency: _groupBy(
        positions: positions,
        totalMarketValue: totalMarketValue,
        labelSelector: (position) => position.currency,
      ),
      byAssetType: _groupBy(
        positions: positions,
        totalMarketValue: totalMarketValue,
        labelSelector: (position) => position.assetType.label,
      ),
    );
  }

  static List<DistributionItem> _groupBy({
    required List<PortfolioPosition> positions,
    required double totalMarketValue,
    required String Function(PortfolioPosition position)
        labelSelector,
  }) {
    final totals = <String, double>{};

    for (final position in positions) {
      final rawLabel = labelSelector(position).trim();

      final label = rawLabel.isEmpty
          ? 'Sin clasificar'
          : rawLabel;

      totals.update(
        label,
        (currentValue) =>
            currentValue + position.currentValue,
        ifAbsent: () => position.currentValue,
      );
    }

    final items = totals.entries.map(
      (entry) {
        final weightPercent = totalMarketValue == 0
            ? 0.0
            : entry.value / totalMarketValue * 100;

        return DistributionItem(
          label: entry.key,
          value: entry.value,
          weightPercent: weightPercent,
        );
      },
    ).toList();

    items.sort(
      (first, second) => second.value.compareTo(
        first.value,
      ),
    );

    return items;
  }
}