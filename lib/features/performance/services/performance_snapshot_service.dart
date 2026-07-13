import 'package:hacela_rendir/core/finance/engine/financial_engine.dart';
import 'package:hacela_rendir/features/performance/data/performance_repository.dart';
import 'package:hacela_rendir/features/performance/domain/performance_snapshot.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/transactions/domain/portfolio_transaction.dart';

class PerformanceSnapshotService {
  PerformanceSnapshotService({
    PerformanceRepository? repository,
  }) : repository =
            repository ?? PerformanceRepository();

  final PerformanceRepository repository;

  Future<PerformanceSnapshot> capture({
    required List<PortfolioTransaction> transactions,
    required List<PortfolioPosition> positions,
    DateTime? recordedAt,
  }) async {
    final date = recordedAt ?? DateTime.now();

    final financialSnapshot =
        FinancialEngine.calculateFromData(
      transactions: transactions,
      positions: positions,
    );

    final netContributions =
        _calculateNetContributions(
      transactions,
    );

    final snapshot = PerformanceSnapshot(
      id: date.microsecondsSinceEpoch.toString(),
      recordedAt: date,
      cashBalance: financialSnapshot.cashBalance,
      marketValue: financialSnapshot.marketValue,
      totalEquity: financialSnapshot.totalEquity,
      netContributions: netContributions,
      investedCapital:
          financialSnapshot.investedCapital,
      totalResult: financialSnapshot.totalResult,
    );

    await repository.addSnapshot(snapshot);

    return snapshot;
  }

  Future<List<PerformanceSnapshot>>
      loadSnapshots() {
    return repository.loadSnapshots();
  }

  double _calculateNetContributions(
    List<PortfolioTransaction> transactions,
  ) {
    var deposits = 0.0;
    var withdrawals = 0.0;

    for (final transaction in transactions) {
      switch (transaction.type) {
        case TransactionType.deposit:
          deposits += transaction.amount;

        case TransactionType.withdrawal:
          withdrawals += transaction.amount;

        case TransactionType.buy:
        case TransactionType.sell:
        case TransactionType.dividend:
        case TransactionType.fee:
          break;
      }
    }

    return deposits - withdrawals;
  }
}