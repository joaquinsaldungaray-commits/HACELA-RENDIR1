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
  final double quantity;
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

  PortfolioPosition copyWith({
    String? ticker,
    String? name,
    double? quantity,
    double? averagePrice,
    double? currentPrice,
  }) {
    return PortfolioPosition(
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
    );
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
      quantity: (json['quantity'] as num).toDouble(),
      averagePrice: (json['averagePrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
    );
  }
}