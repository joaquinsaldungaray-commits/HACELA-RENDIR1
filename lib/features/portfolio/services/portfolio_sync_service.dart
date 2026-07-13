import 'package:hacela_rendir/features/portfolio/data/portfolio_repository.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/portfolio/services/position_builder.dart';
import 'package:hacela_rendir/features/transactions/data/transaction_repository.dart';

class PortfolioSyncService {
  PortfolioSyncService({
    PortfolioRepository? portfolioRepository,
    TransactionRepository? transactionRepository,
  })  : portfolioRepository =
            portfolioRepository ?? PortfolioRepository(),
        transactionRepository =
            transactionRepository ?? TransactionRepository();

  final PortfolioRepository portfolioRepository;
  final TransactionRepository transactionRepository;

  Future<List<PortfolioPosition>> syncFromTransactions() async {
    final transactions =
        await transactionRepository.loadTransactions();

    final positions = PositionBuilder.buildFromTransactions(
      transactions,
    );

    await portfolioRepository.savePositions(
      positions,
    );

    return positions;
  }
}