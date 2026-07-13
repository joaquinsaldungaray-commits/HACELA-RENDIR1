import 'package:hacela_rendir/features/portfolio/data/portfolio_repository.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';
import 'package:hacela_rendir/features/portfolio/services/portfolio_enrichment_service.dart';
import 'package:hacela_rendir/features/portfolio/services/position_builder.dart';
import 'package:hacela_rendir/features/transactions/data/transaction_repository.dart';

class PortfolioSyncService {
  PortfolioSyncService({
    PortfolioRepository? portfolioRepository,
    TransactionRepository? transactionRepository,
    PortfolioEnrichmentService? enrichmentService,
  })  : portfolioRepository =
            portfolioRepository ?? PortfolioRepository(),
        transactionRepository =
            transactionRepository ?? TransactionRepository(),
        enrichmentService = enrichmentService ??
            const PortfolioEnrichmentService();

  final PortfolioRepository portfolioRepository;
  final TransactionRepository transactionRepository;
  final PortfolioEnrichmentService enrichmentService;

  Future<List<PortfolioPosition>> syncFromTransactions() async {
    final transactions =
        await transactionRepository.loadTransactions();

    final calculatedPositions =
        PositionBuilder.buildFromTransactions(
      transactions,
    );

    final enrichedPositions =
        await enrichmentService.enrichPositions(
      calculatedPositions,
    );

    enrichedPositions.sort(
      (first, second) => second.currentValue.compareTo(
        first.currentValue,
      ),
    );

    await portfolioRepository.savePositions(
      enrichedPositions,
    );

    return enrichedPositions;
  }
}