class DistributionItem {
  const DistributionItem({
    required this.label,
    required this.value,
    required this.weightPercent,
  });

  final String label;
  final double value;
  final double weightPercent;
}

class PortfolioDistribution {
  const PortfolioDistribution({
    required this.bySector,
    required this.byCountry,
    required this.byCurrency,
    required this.byAssetType,
  });

  final List<DistributionItem> bySector;
  final List<DistributionItem> byCountry;
  final List<DistributionItem> byCurrency;
  final List<DistributionItem> byAssetType;
}