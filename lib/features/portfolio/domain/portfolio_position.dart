class PortfolioPosition {
  final String ticker;
  final String name;
  final int quantity;
  final double averagePrice;
  final double currentPrice;

  const PortfolioPosition({
    required this.ticker,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
  });

  double get invested => quantity * averagePrice;

  double get currentValue => quantity * currentPrice;

  double get profit => currentValue - invested;

  double get profitability =>
      invested == 0 ? 0 : (profit / invested) * 100;
}