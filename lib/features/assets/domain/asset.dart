import 'package:hacela_rendir/features/assets/domain/asset_type.dart';

class Asset {
  const Asset({
    required this.symbol,
    required this.name,
    required this.type,
    required this.exchange,
    required this.country,
    required this.currency,
    required this.sector,
    required this.industry,
    this.isin,
    this.description,
  });

  final String symbol;
  final String name;
  final AssetType type;

  final String exchange;
  final String country;
  final String currency;

  final String sector;
  final String industry;

  final String? isin;
  final String? description;

  Asset copyWith({
    String? symbol,
    String? name,
    AssetType? type,
    String? exchange,
    String? country,
    String? currency,
    String? sector,
    String? industry,
    String? isin,
    String? description,
  }) {
    return Asset(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      exchange: exchange ?? this.exchange,
      country: country ?? this.country,
      currency: currency ?? this.currency,
      sector: sector ?? this.sector,
      industry: industry ?? this.industry,
      isin: isin ?? this.isin,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'type': type.name,
      'exchange': exchange,
      'country': country,
      'currency': currency,
      'sector': sector,
      'industry': industry,
      'isin': isin,
      'description': description,
    };
  }

  factory Asset.fromJson(
    Map<String, dynamic> json,
  ) {
    return Asset(
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      type: AssetType.values.firstWhere(
        (type) => type.name == json['type'],
        orElse: () => AssetType.other,
      ),
      exchange: json['exchange'] as String,
      country: json['country'] as String,
      currency: json['currency'] as String,
      sector: json['sector'] as String,
      industry: json['industry'] as String,
      isin: json['isin'] as String?,
      description: json['description'] as String?,
    );
  }
}