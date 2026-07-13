import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

abstract final class CashCalculator {
  static double calculate(
    List<PortfolioTransaction> transactions,
  ) {
    return transactions.fold<double>(
      0,
      (cash, transaction) {
        return cash + transaction.netCashFlow;
      },
    );
  }
}