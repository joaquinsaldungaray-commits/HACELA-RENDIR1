import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/transactions/domain/investment_result_summary.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

abstract final class InvestmentResultCalculator {
  static InvestmentResultSummary calculate({
    required List<PortfolioTransaction> transactions,
    required List<PortfolioPosition> openPositions,
  }) {
    var realizedProfit = 0.0;
    var dividends = 0.0;
    var fees = 0.0;

    final accumulators = <String, _RealizedPositionAccumulator>{};

    final orderedTransactions =
        List<PortfolioTransaction>.from(transactions)
          ..sort(
            (first, second) => first.date.compareTo(second.date),
          );

    for (final transaction in orderedTransactions) {
      switch (transaction.type) {
        case TransactionType.buy:
          final ticker = _normalizedTicker(transaction);

          if (ticker == null) {
            break;
          }

          final accumulator = accumulators.putIfAbsent(
            ticker,
            _RealizedPositionAccumulator.new,
          );

          accumulator.addPurchase(
            quantity: transaction.quantity,
            price: transaction.price,
            fee: transaction.fee,
          );

          fees += transaction.fee;

        case TransactionType.sell:
          final ticker = _normalizedTicker(transaction);

          if (ticker == null) {
            break;
          }

          final accumulator = accumulators.putIfAbsent(
            ticker,
            _RealizedPositionAccumulator.new,
          );

          realizedProfit += accumulator.addSale(
            quantity: transaction.quantity,
            price: transaction.price,
            fee: transaction.fee,
          );

          fees += transaction.fee;

        case TransactionType.dividend:
          dividends += transaction.amount;

        case TransactionType.fee:
          fees += transaction.amount;
          realizedProfit -= transaction.amount;

        case TransactionType.deposit:
        case TransactionType.withdrawal:
          break;
      }
    }

    final unrealizedProfit = openPositions.fold<double>(
      0,
      (total, position) => total + position.profit,
    );

    final totalResult =
        realizedProfit + unrealizedProfit + dividends;

    return InvestmentResultSummary(
      realizedProfit: realizedProfit,
      unrealizedProfit: unrealizedProfit,
      dividends: dividends,
      fees: fees,
      totalResult: totalResult,
    );
  }

  static String? _normalizedTicker(
    PortfolioTransaction transaction,
  ) {
    final ticker = transaction.ticker?.trim().toUpperCase();

    if (ticker == null || ticker.isEmpty) {
      return null;
    }

    return ticker;
  }
}

class _RealizedPositionAccumulator {
  double quantity = 0;
  double totalCost = 0;

  void addPurchase({
    required double quantity,
    required double price,
    required double fee,
  }) {
    if (quantity <= 0 || price <= 0) {
      return;
    }

    this.quantity += quantity;
    totalCost += quantity * price + fee;
  }

  double addSale({
    required double quantity,
    required double price,
    required double fee,
  }) {
    if (quantity <= 0 || price <= 0 || this.quantity <= 0) {
      return 0;
    }

    final quantityToSell = quantity > this.quantity
        ? this.quantity
        : quantity;

    final averageCost = totalCost / this.quantity;
    final saleProceeds = quantityToSell * price - fee;
    final soldCost = quantityToSell * averageCost;

    final realizedProfit = saleProceeds - soldCost;

    totalCost -= soldCost;
    this.quantity -= quantityToSell;

    if (this.quantity <= 0.00000001) {
      this.quantity = 0;
      totalCost = 0;
    }

    return realizedProfit;
  }
}