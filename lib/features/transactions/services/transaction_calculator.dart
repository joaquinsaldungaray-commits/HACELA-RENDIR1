import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';
import 'package:hacela_rendir/features/transactions/domain/transaction_summary.dart';

abstract final class TransactionCalculator {
  static TransactionSummary calculate(
    List<PortfolioTransaction> transactions,
  ) {
    var purchases = 0.0;
    var sales = 0.0;
    var dividends = 0.0;
    var fees = 0.0;
    var deposits = 0.0;
    var withdrawals = 0.0;
    var netCashFlow = 0.0;

    for (final transaction in transactions) {
      netCashFlow += transaction.netCashFlow;

      switch (transaction.type) {
        case TransactionType.buy:
          purchases += transaction.grossValue;
          fees += transaction.fee;

        case TransactionType.sell:
          sales += transaction.grossValue;
          fees += transaction.fee;

        case TransactionType.dividend:
          dividends += transaction.amount;

        case TransactionType.fee:
          fees += transaction.amount;

        case TransactionType.deposit:
          deposits += transaction.amount;

        case TransactionType.withdrawal:
          withdrawals += transaction.amount;
      }
    }

    return TransactionSummary(
      totalPurchases: purchases,
      totalSales: sales,
      totalDividends: dividends,
      totalFees: fees,
      totalDeposits: deposits,
      totalWithdrawals: withdrawals,
      netCashFlow: netCashFlow,
      transactionCount: transactions.length,
    );
  }
}