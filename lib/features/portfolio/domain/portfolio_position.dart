class PortfolioPosition {
  const PortfolioPosition({
    required this.ticker,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
  });

  final String ticker;
  final String name;
  final int quantity;
  final double averagePrice;
  final double currentPrice;

  double get invested => quantity * averagePrice;

  double get currentValue => quantity * currentPrice;

  double get profit => currentValue - invested;

  double get profitability {
    if (invested == 0) {
      return 0;
    }

    return profit / invested * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'name': name,
      'quantity': quantity,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
    };
  }

  factory PortfolioPosition.fromJson(
    Map<String, dynamic> json,
  ) {
    return PortfolioPosition(
      ticker: json['ticker'] as String,
      name: json['name'] as String,
      quantity: json['quantity'] as int,
      averagePrice: (json['averagePrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
    );
  }
}