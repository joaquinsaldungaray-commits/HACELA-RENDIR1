enum TransactionType {
  buy,
  sell,
  dividend,
  fee,
  deposit,
  withdrawal,
}

class PortfolioTransaction {
  const PortfolioTransaction({
    required this.id,
    required this.type,
    required this.date,
    this.ticker,
    this.assetName,
    this.quantity = 0,
    this.price = 0,
    this.amount = 0,
    this.fee = 0,
    this.notes = '',
  });

  final String id;
  final TransactionType type;
  final DateTime date;

  final String? ticker;
  final String? assetName;

  final double quantity;
  final double price;
  final double amount;
  final double fee;

  final String notes;

  double get grossValue {
    switch (type) {
      case TransactionType.buy:
      case TransactionType.sell:
        return quantity * price;

      case TransactionType.dividend:
      case TransactionType.fee:
      case TransactionType.deposit:
      case TransactionType.withdrawal:
        return amount;
    }
  }

  double get netCashFlow {
    switch (type) {
      case TransactionType.buy:
        return -(grossValue + fee);

      case TransactionType.sell:
        return grossValue - fee;

      case TransactionType.dividend:
      case TransactionType.deposit:
        return amount;

      case TransactionType.fee:
      case TransactionType.withdrawal:
        return -amount;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'date': date.toIso8601String(),
      'ticker': ticker,
      'assetName': assetName,
      'quantity': quantity,
      'price': price,
      'amount': amount,
      'fee': fee,
      'notes': notes,
    };
  }

  factory PortfolioTransaction.fromJson(
    Map<String, dynamic> json,
  ) {
    return PortfolioTransaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (type) => type.name == json['type'],
      ),
      date: DateTime.parse(
        json['date'] as String,
      ),
      ticker: json['ticker'] as String?,
      assetName: json['assetName'] as String?,
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      fee: (json['fee'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}