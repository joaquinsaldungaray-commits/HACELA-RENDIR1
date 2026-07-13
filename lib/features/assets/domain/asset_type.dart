enum AssetType {
  stock,
  etf,
  bond,
  crypto,
  commodity,
  currency,
  fund,
  option,
  future,
  cash,
  other,
}

extension AssetTypeLabel on AssetType {
  String get label {
    return switch (this) {
      AssetType.stock => 'Acción',
      AssetType.etf => 'ETF',
      AssetType.bond => 'Bono',
      AssetType.crypto => 'Criptomoneda',
      AssetType.commodity => 'Materia prima',
      AssetType.currency => 'Moneda',
      AssetType.fund => 'Fondo',
      AssetType.option => 'Opción',
      AssetType.future => 'Futuro',
      AssetType.cash => 'Efectivo',
      AssetType.other => 'Otro',
    };
  }
}