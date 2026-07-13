import 'package:hacela_rendir/features/assets/domain/asset_type.dart';

class PortfolioPosition {
  const PortfolioPosition({
    required this.ticker,
    required this.name,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    this.assetType = AssetType.other,
    this.exchange = 'Sin información',
    this.country = 'Sin información',
    this.currency = 'USD',
    this.sector = 'Sin clasificar',
    this.industry = 'Sin clasificar',
  });

  final String ticker;
  final String name;

  final double quantity;
  final double averagePrice;
  final double currentPrice;

  final AssetType assetType;
  final String exchange;
  final String country;
  final String currency;
  final String sector;
  final String industry;

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
    AssetType? assetType,
    String? exchange,
    String? country,
    String? currency,
    String? sector,
    String? industry,
  }) {
    return PortfolioPosition(
      ticker: ticker ?? this.ticker,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      assetType: assetType ?? this.assetType,
      exchange: exchange ?? this.exchange,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'name': name,
      'quantity': quantity,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'assetType': assetType.name,
      'exchange': exchange,
      'country': country,
      'currency': currency,
      'sector': sector,
      'industry': industry,
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
      assetType: AssetType.values.firstWhere(
        (type) => type.name == json['assetType'],
        orElse: () => AssetType.other,
      ),
      exchange:
          json['exchange'] as String? ?? 'Sin información',
      country:
          json['country'] as String? ?? 'Sin información',
      currency: json['currency'] as String? ?? 'USD',
      sector: json['sector'] as String? ?? 'Sin clasificar',
      industry:
          json['industry'] as String? ?? 'Sin clasificar',
    );
  }
}