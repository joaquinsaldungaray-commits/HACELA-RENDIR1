import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

abstract final class PositionBuilder {
  static List<PortfolioPosition> buildFromTransactions(
    List<PortfolioTransaction> transactions,
  ) {
    final positionsByTicker = <String, _PositionAccumulator>{};

    final orderedTransactions = List<PortfolioTransaction>.from(
      transactions,
    )..sort(
        (first, second) => first.date.compareTo(second.date),
      );

    for (final transaction in orderedTransactions) {
      final ticker = transaction.ticker?.trim().toUpperCase();

      if (ticker == null || ticker.isEmpty) {
        continue;
      }

      if (transaction.type != TransactionType.buy &&
          transaction.type != TransactionType.sell) {
        continue;
      }

      final accumulator = positionsByTicker.putIfAbsent(
        ticker,
        () => _PositionAccumulator(
          ticker: ticker,
          name: transaction.assetName?.trim().isNotEmpty == true
              ? transaction.assetName!.trim()
              : ticker,
        ),
      );

      if (transaction.type == TransactionType.buy) {
        accumulator.addPurchase(
          quantity: transaction.quantity,
          price: transaction.price,
          fee: transaction.fee,
          name: transaction.assetName,
        );
      }

      if (transaction.type == TransactionType.sell) {
        accumulator.addSale(
          quantity: transaction.quantity,
          price: transaction.price,
        );
      }
    }

    final positions = positionsByTicker.values
        .where(
          (accumulator) => accumulator.quantity > 0,
        )
        .map(
          (accumulator) => accumulator.toPosition(),
        )
        .toList();

    positions.sort(
      (first, second) => second.currentValue.compareTo(
        first.currentValue,
      ),
    );

    return positions;
  }
}

class _PositionAccumulator {
  _PositionAccumulator({
    required this.ticker,
    required this.name,
  });

  final String ticker;

  String name;
  double quantity = 0;
  double totalCost = 0;
  double currentPrice = 0;

  void addPurchase({
    required double quantity,
    required double price,
    required double fee,
    String? name,
  }) {
    if (quantity <= 0 || price <= 0) {
      return;
    }

    final purchaseCost = quantity * price + fee;

    this.quantity += quantity;
    totalCost += purchaseCost;
    currentPrice = price;

    if (name != null && name.trim().isNotEmpty) {
      this.name = name.trim();
    }
  }

  void addSale({
    required double quantity,
    required double price,
  }) {
    if (quantity <= 0 || price <= 0 || this.quantity <= 0) {
      return;
    }

    final quantityToSell = quantity > this.quantity
        ? this.quantity
        : quantity;

    final averagePrice = this.quantity == 0
        ? 0
        : totalCost / this.quantity;

    totalCost -= averagePrice * quantityToSell;
    this.quantity -= quantityToSell;
    currentPrice = price;

    if (this.quantity <= 0.00000001) {
      this.quantity = 0;
      totalCost = 0;
    }
  }

  PortfolioPosition toPosition() {
    final averagePrice = quantity == 0
        ? 0.0
        : totalCost / quantity;

    return PortfolioPosition(
      ticker: ticker,
      name: name,
      quantity: quantity,
      averagePrice: averagePrice,
      currentPrice: currentPrice,
    );
  }
}