import 'package:hacela_rendir/features/assets/services/asset_lookup_service.dart';
import 'package:hacela_rendir/features/portfolio/domain/portfolio_position.dart';

class PortfolioEnrichmentService {
  const PortfolioEnrichmentService({
    AssetLookupService? assetLookupService,
  }) : assetLookupService =
            assetLookupService ?? const AssetLookupService();

  final AssetLookupService assetLookupService;

  Future<List<PortfolioPosition>> enrichPositions(
    List<PortfolioPosition> positions,
  ) async {
    final enrichedPositions = <PortfolioPosition>[];

    for (final position in positions) {
      final asset = await assetLookupService.findBySymbol(
        position.ticker,
      );

      if (asset == null) {
        enrichedPositions.add(position);
        continue;
      }

      enrichedPositions.add(
        position.copyWith(
          ticker: asset.symbol,
          name: asset.name,
          assetType: asset.type,
          exchange: asset.exchange,
          country: asset.country,
          currency: asset.currency,
          sector: asset.sector,
          industry: asset.industry,
        ),
      );
    }

    return enrichedPositions;
  }
}